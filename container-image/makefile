IMAGE_NAME = quay.io/kubermatic-labs/training-ghcs-advanced-operations-of-kubernetes-with-kubeone-trainee-environment
IMAGE_TAG = 2.0.0
CONTAINER_NAME=k1-workshop

.PHONY: clear
clear:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: lint
lint:
	hadolint ./dockerfile

.PHONY: build
build: lint
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: run
run: build
	docker rm --force $(CONTAINER_NAME)
	docker run -it -d --platform linux/amd64 \
		--name $(CONTAINER_NAME) \
		--restart=always \
		--cpus=2 \
		--memory=4g \
		-p 8080:8080 \
		-p 8081:8081 \
		-p 8082:8082 \
		--hostname k1-workshop \
		-v $(PWD)/..:/training \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: push
push: build
	docker push ${IMAGE_NAME}:${IMAGE_TAG}
