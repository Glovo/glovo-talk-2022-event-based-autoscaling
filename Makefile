SHELL := bash

# .PHONY: install
# install:
# 	brew install -q kind helm python3 && \

.PHONY: init
init:
	@echo "Creating environment"
	#TODO SEE IF I CAN FIX kind create cluster --name event-based-autoscaling-demo --image kindest/node:v1.22.15 --config resources/keda.yaml && \
	kind create cluster --name event-based-autoscaling-demo --image kindest/node:v1.22.15 && \
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ && \
	helm repo add kedacore https://kedacore.github.io/charts && \
	helm repo add localstack-repo https://helm.localstack.cloud && \
	helm repo update && \
	helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system
	helm upgrade --install keda kedacore/keda --namespace keda --create-namespace && \
	helm upgrade --install localstack localstack-repo/localstack && \
	python3 -m pip install virtualenv && \
	python3 -m virtualenv .venv && \
	source .venv/bin/activate && \
	python3 -m pip install awscli-local && \
	export NODE_PORT=$(kubectl get --namespace "default" -o jsonpath="{.spec.ports[0].nodePort}" services localstack) && \
  	export NODE_IP=$(kubectl get nodes --namespace "default" -o jsonpath="{.items[0].status.addresses[0].address}") && \
	aws --endpoint-url http://$NODE_IP:$NODE_PORT sqs create-queue --queue-name sample-queue && \

.PHONY: deploy
deploy:
	kubectl apply -f resources/deployment.yaml -f resources/keda.yaml

load:
	@echo "Sending load to queue"
	awslocal sqs send-message --queue-url http://localhost:4566/000000000000/sample-queue --message-body test &
	awslocal sqs send-message --queue-url http://localhost:4566/000000000000/sample-queue --message-body test &
	awslocal sqs send-message --queue-url http://localhost:4566/000000000000/sample-queue --message-body test &