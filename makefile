.PHONY verify:
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	kubectl version --client
	gcloud version
	terraform version
	test -n "$(K8S_VERSION)"
	test -n "$(TF_VERSION)"
	ssh-add -l # TODO ensure that is the right ssh key
	echo "Training Environment successfully verified"

.PHONY teardown:
teardown:
	terraform destroy