.PHONY verify:
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	kubectl version --client
	terraform version
	kubeone version
	test -n "$(K8S_VERSION)"
	test -n "$(TF_VERSION)"
	test -n "$(K1_VERSION)"
	ssh-add -l
	echo "Training Environment successfully verified"

