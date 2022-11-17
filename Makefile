SHELL := bash

.PHONY: init
init:
	@echo "Creating environment"
	kind create cluster --name event-based-autoscaling-demo --image kindest/node:v1.22.15 && \
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ && \
	helm repo add kedacore https://kedacore.github.io/charts && \
	helm repo update && \
	helm upgrade --install --set args={--kubelet-insecure-tls} metrics-server metrics-server/metrics-server --namespace kube-system && \
	helm upgrade --install keda kedacore/keda --namespace keda --create-namespace

.PHONY: deploy
deploy:
	kubectl apply -f resources/deployment.yaml -f resources/keda.yaml

.PHONY: load
load:
	@echo "Sending load to queue"
	aws sqs send-message --queue-url <QUEUE_URL> --message-body message1 & 
	aws sqs send-message --queue-url <QUEUE_URL> --message-body message2 & 
	aws sqs send-message --queue-url <QUEUE_URL> --message-body message3 & 
	aws sqs send-message --queue-url <QUEUE_URL> --message-body message4 & 
	aws sqs send-message --queue-url <QUEUE_URL> --message-body message5 & 