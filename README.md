# Chain Deployment Test

Universal interchain development environment in k8s. The vision of this project
is to have a single easy to use developer environment with full testing support
for multichain use cases

## Installation
Inorder to get started with project, one needs to install the following
* `kubectl`: https://kubernetes.io/docs/tasks/tools/
* `helm`: https://helm.sh/docs/intro/install/
* `jq`: https://stedolan.github.io/jq/download/
* `yq`: https://github.com/mikefarah/yq/#install
* `Kubernetes Cluster`(In this project, I used minikube): https://minikube.sigs.k8s.io/docs/start/

To install these, you can use the handy make commands in the `Makefile` like following.
```bash
make set-environment
```
This will install kubectl, helm, jq and yq, but not install minikube because this is optional. You can use your own k8s cluster or minikube. If you want to install minikube and use this, installation step is below.

## Getting started
Update the `vaules.yaml` in `devnet/templates`. Recommeded one creates a copy of the values file and update it as per your requirements.

### Setup local k8s cluster (optional)
Create a local k8s cluster using `minikube`. 
One can use the handy make commands in the `Makefile` like following
```bash
# If you didn't install docker (This command is optional)
make setup-docker

make setup-minikube
```
This will create a local k8s cluster in docker and set the correct context in
your current kubectl. Check the kubectl context with
```bash
kubectl config current-context
# check: minikube
```

### Setup minikube cluster
1. Connect to a k8s cluster, make sure you are able to access following command
   ```bash
   kubectl get pods
   ```
2. Create a namespace in which the setup will be deployed.
   ```bash
   kubectl create namespace <namespace-name>
   # example
   kubectl create namespace testProject
   ```
    You can set working namespace by run following command.
    ```bash
    kubectl config set-context --current --namespace=<namespace-name>
    # example
    kubectl config set-context --current --namespace=testProject
    ```
3. Make sure you have set the namespace in the current context, so the devnet is deployed without conflict to your current workloads

### Start
1. Debug the k8s yaml configuration files
   ```bash
   make debug VALUES_NAME=<custom-filename>
   # output all yaml files that will be deployed 
   # default values file run
   make debug
   ```
2. Start the cluster
   ```bash
   make install VALUES_NAME=<custom-filename>
   # default values file run
   make install
   ```
   Optionally you can use k9s, to watch all the fun
3. Once you make any changes to the system or values, run
   ```bash
   make upgrade VALUES_NAME=<custom-filename>
   # default values file run
   make upgrade
   ```
4. Run local port forwarding based on local port info in the `values.yaml`
   ```bash
   # port-forward all the local ports locally, runs in background
   make port-forward-all
   
   # Run following to stop port forwarding once done
   make stop-forward
   ```
   Sometime one might need to run connection updates so the port-forward does not
   get timed out. Run `make check-forward-all`
5. Open the explorer at `http://localhost:5173`
6. To clean up everything run
   ```bash
   # Kill any portforwarding
   make stop-forward
   # Delete current helm chart deployment
   make delete
   # If running local k8s cluster, cleanup
   make stop-minikube
   ```

# Future works
* In most cases, we use sentry architecture to protect validator from several kinds of attacks such as DDoS(Distributed Denial of Service) attack or others. But in this project, there is no sentry node, but in future, to protect validator nodes in production environment, I will implement sentry architecture.