# Set helm args based on only file to show
HELM_NAME = testproject
ifneq ($(FILE),)
HELM_ARGS += --show-only $(FILE)
endif

KEYS_CONFIG = configs/keys.json
VALUES_FILE = values.yaml


###############################################################################
###                            Minikube Install                             ###
###############################################################################

install-minikube:
ifeq ($(shell uname -s), Linux)
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube
	rm minikube-linux-amd64
else
	brew install minikube
endif

install-docker:
ifeq ($(shell uname -s), Linux)
	sudo apt install docker.io
else
	brew install docker
endif

minikube_check := $(shell command -v minikube 2> /dev/null)
docker_check := $(shell command -v docker 2> /dev/null)

setup-docker:
ifndef docker_check
	$(MAKE) install-docker
	sleep 1
	sudo usermod -aG docker $(USER) && newgrp docker 
endif

setup-minikube:
ifndef minikube_check
	$(MAKE) install-minikube
	minikube start
endif
	echo "minikube already installed"

stop-minikube:
	minikube stop

###############################################################################
###                              jq Install                                 ###
###############################################################################

install-jq:
ifeq ($(shell uname -s), Linux)
	sudo apt update;
	sudo apt install -y jq
else
	brew install jq
endif

jq_check := $(shell command -v yq 2> /dev/null)
setup-jq:
ifndef jq_check
	$(MAKE) install-jq
	echo "jq installed successfully"
else
	echo "jq already installed"
endif

###############################################################################
###                              yq Install                                 ###
###############################################################################

install-yq:
ifeq ($(shell uname -s), Linux)
	sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    	sudo chmod +x /usr/bin/yq
else
	brew install yq
endif

yq_check := $(shell command -v yq 2> /dev/null)
setup-yq:
ifndef yq_check
	$(MAKE) install-yq
	echo "yq installed successfully"
else
	echo "yq already installed"
endif

###############################################################################
###                            Kubectl Install                              ###
###############################################################################

install-kubectl:
ifeq ($(shell uname -s), Linux)
	sudo snap install kubectl --classic
else
	brew install kubectl
endif

kubectl_check := $(shell command -v kubectl 2> /dev/null)
setup-kubectl:
ifndef kubectl_check
	$(MAKE) install-kubectl
endif
	echo "kubectl already installed"

###############################################################################
###                              Helm Install                               ###
###############################################################################

install-helm:
ifeq ($(shell uname -s), Linux)
	sudo snap install helm --classic
else
	brew install helm
endif

helm_check := $(shell command -v helm 2> /dev/null)
setup-helm:
ifndef helm_check
	$(MAKE) install-helm
endif
	echo "helm already installed"

###############################################################################
###                              Set environment                            ###
###############################################################################

set-environment:
	$(MAKE) setup-jq
	$(MAKE) setup-yq
	$(MAKE) setup-kubectl
	$(MAKE) setup-helm

###############################################################################
###                              Helm commands                              ###
###############################################################################

debug:
	helm template --dry-run --debug --generate-name ./ -f $(VALUES_FILE) $(HELM_ARGS)

install:
	helm install --replace $(HELM_NAME) ./ -f $(VALUES_FILE) $(HELM_ARGS)

upgrade:
	helm upgrade $(HELM_NAME) ./ -f $(VALUES_FILE) $(HELM_ARGS)

test:
	helm test --debug $(HELM_NAME)

delete:
	helm delete $(HELM_NAME)

###############################################################################
###                              Port forward                               ###
###############################################################################

.PHONY: port-forward-all
port-forward-all:
	$(CURDIR)/config-scripts/port-forward.sh -c=$(VALUES_FILE)

.PHONY: stop-forward
stop-forward:
	-pkill -f "port-forward"

