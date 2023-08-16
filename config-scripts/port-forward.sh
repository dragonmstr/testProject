#!/bin/bash
. "$(dirname "$0")"/common.sh

echo "HERE"

set -euo pipefail

function stop_port_forward() {
    color 33 "Trying to stop all port-forward, if any,..."
    PIDS=$(ps -ef | grep -i -e 'kubectl port-forward' | grep -v 'grep' | cat | awk '{print $2}') || true
    for pid in $PIDS
    do
        kill -15 $pid
    done
}

# Default Values
CHAIN_RPC_PORT=26657
CHAIN_LCD_PORT=1317
EXPLORER_LCD_PORT=5173
REGISTRY_LCD_PORT=8081
REGISTRY_GRPC_PORT=9090

for i in "$@"; do
  case $i in
    -c=*|--config=*)
      CONFIGFILE="${i#*=}"
      shift # past argument=value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

stop_port_forward

echo "Port forwarding for config ${CONFIGFILE}"
echo "Port forwarding all chains"
num_chains=$(yq -r ".chains | length" ${CONFIGFILE})
if [[ $num_chains -lt 1 ]]; then
  echo "No chains to port-forward"
  exit 1
fi
for i in $(seq 0 $(($num_chains - 1))); do
  chain=$(yq -r ".chains[$i].name" ${CONFIGFILE} )
  localrpc=$(yq -r ".chains[$i].ports.rpc" ${CONFIGFILE} )
  locallcd=$(yq -r ".chains[$i].ports.rest" ${CONFIGFILE} )
  kubectl port-forward pods/$chain-genesis-0 $localrpc:$CHAIN_RPC_PORT > /dev/null 2>&1 &
  kubectl port-forward pods/$chain-genesis-0 $locallcd:$CHAIN_LCD_PORT > /dev/null 2>&1 &
  sleep 1
  color $YELLOW "chains: forwarded $chain lcd to http://localhost:$locallcd, rpc to http://localhost:$localrpc"
done

echo "Port forward services"

if [[ $(yq -r ".registry.enabled" $CONFIGFILE) == "true" ]];
then
  kubectl port-forward service/registry 8081:$REGISTRY_LCD_PORT > /dev/null 2>&1 &
  kubectl port-forward service/registry 9091:$REGISTRY_GRPC_PORT > /dev/null 2>&1 &
  sleep 1
  color $YELLOW "registry: forwarded registry lcd to grpc http://localhost:8081, to http://localhost:9091"
fi

if [[ $(yq -r ".explorer.enabled" $CONFIGFILE) == "true" ]];
then
  kubectl port-forward service/explorer --address=0.0.0.0 5173:$EXPLORER_LCD_PORT > /dev/null 2>&1 &
  sleep 1
  color $GREEN "Open the explorer to get started.... http://localhost:5173"
fi
