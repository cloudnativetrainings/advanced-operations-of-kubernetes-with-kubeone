.PHONY: verify
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.zshrc
	kubectl version --client
	gcloud version
	terraform version
	kubectx
	helm version
	velero version --client-only
	test -n "$(GCP_PROJECT)"
	test -n "$(TRAINEE_NAME)"
	test -n "$(DOMAIN)"
	test -n "$(DNS_ZONE_NAME)"
	test -n "$(TRAINEE_EMAIL)"
	test -n "$(S3_BUCKET)"
# TODO	kubens => failing due no cluster yet
	test -n "$(K8S_VERSION)"
	test -n "$(TF_VERSION)"
	test -e /training/.secrets/gcp
	test -e /training/.secrets/gcp.pub
# TODO ensure that is the right ssh key - ssh-add -l | grep "$(ssh-keygen -lf .secrets/gce)"
	test -e /training/.secrets/gcp-service-account.json
# TODO test -v $(GOOGLE_CREDENTIALS)
# TODO verify gcp sa permissions
	echo "Training Environment successfully verified"
