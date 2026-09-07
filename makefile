.PHONY: verify
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	kubectl version --client
	gcloud version
	terraform version
	kubectx
	helm version
	velero version --client-only
	test -n "$(GCE_PROJECT)" 
	test -n "$(TRAINEE_NAME)" 
	test -n "$(DOMAIN)" 
	test -n "$(DNS_ZONE_NAME)" 
# TODO	kubens => failing due no cluster yet
	test -n "$(K8S_VERSION)" 
	test -n "$(TF_VERSION)" 
	test -e /training/.secrets/gce
	test -e /training/.secrets/gce.pub
# TODO ensure that is the right ssh key - ssh-add -l | grep "$(ssh-keygen -lf .secrets/gce)"
	test -e /training/.secrets/gcloud-service-account.json 
# TODO test -v $(GOOGLE_CREDENTIALS)
# TODO verify gcp sa permissions
	echo "Training Environment successfully verified"

IMAGE_NAME=kubeone
IMAGE_TAG=0.0.0

.PHONY: clear
clear:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: lint
lint:
	hadolint ./container-image/dockerfile 

.PHONY: build
build: lint
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) ./container-image/

.PHONY: run
run: build
	docker run -it -d \
		--restart=always \
		-p 8080:8080 \
		--hostname jumphost \
		-v $(PWD):/training \
		$(IMAGE_NAME):$(IMAGE_TAG)

# TODO compose? healthchecks?		

# .PHONY: ssh-controlplane-node
# ssh-controlplane-node:
# 	ssh -F /training/.secrets/ssh-config controlplane-node  

# .PHONY: ssh-worker-node
# ssh-worker-node:
# 	ssh -F /training/.secrets/ssh-config worker-node  

# .PHONY: restart
# restart:
# 	ssh -F /training/.secrets/ssh-config controlplane-node 'bash -s' < /training/99_teardown/teardown.sh
# 	ssh -F /training/.secrets/ssh-config worker-node 'bash -s' < /training/99_teardown/teardown.sh