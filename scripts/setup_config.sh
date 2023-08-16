#!/bin/bash

CHAIN_ID="${CHAIN_ID:=osmosis}"
CHAIN_DIR="${CHAIN_DIR:=$HOME/.osmosisd}"
KEYS_CONFIG="${KEYS_CONFIG:=configs/keys.json}"

set -eu

ls $CHAIN_DIR

echo "Update config.toml file"
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' $CHAIN_DIR/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/config/config.toml
sed -i -e 's/seeds = ".*"/seeds = ""/g' $CHAIN_DIR/config/config.toml

echo "Update client.toml file"
sed -i -e 's#keyring-backend = "os"#keyring-backend = "test"#g' $CHAIN_DIR/config/client.toml
sed -i -e 's#output = "text"#output = "json"#g' $CHAIN_DIR/config/client.toml
sed -i -e 's#broadcast-mode = "sync"#broadcast-mode = "block"#g' $CHAIN_DIR/config/client.toml
sed -i -e "s#chain-id = \"\"#chain-id = \"$CHAIN_ID\"#g" $CHAIN_DIR/config/client.toml

echo "Update app.toml file"
sed -i -e "s#minimum-gas-prices = \".*\"#minimum-gas-prices = \"0$DENOM\"#g" $CHAIN_DIR/config/app.toml
sed -i -e "s#pruning = \".*\"#pruning = \"default\"#g" $CHAIN_DIR/config/app.toml
sed -i -z -e 's/Enable defines if the API server should be enabled.\nenable = false/Enable defines if the API server should be enabled.\nenable = true/g' $CHAIN_DIR/config/app.toml
sed -i -e 's#enabled-unsafe-cors = false#enabled-unsafe-cors = true#g' $CHAIN_DIR/config/app.toml
sed -i -e 's#swagger = false#swagger = true#g' $CHAIN_DIR/config/app.toml

echo "Update consensus params in config.toml"
sed -i -e "s#timeout_propose = \".*\"#timeout_propose = \"$TIMEOUT_PROPOSE\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_propose_delta = \".*\"#timeout_propose_delta = \"$TIMEOUT_PROPOSE_DELTA\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_prevote = \".*\"#timeout_prevote = \"$TIMEOUT_PREVOTE\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_prevote_delta = \".*\"#timeout_prevote_delta = \"$TIMEOUT_PREVOTE_DELTA\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_precommit = \".*\"#timeout_precommit = \"$TIMEOUT_PRECOMMIT\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_precommit_delta = \".*\"#timeout_precommit_delta = \"$TIMEOUT_PRECOMMIT_DELTA\"#g" $CHAIN_DIR/config/config.toml
sed -i -e "s#timeout_commit = \".*\"#timeout_commit = \"$TIMEOUT_COMMIT\"#g" $CHAIN_DIR/config/config.toml

$CHAIN_BIN tendermint show-node-id
