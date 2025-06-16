.PHONY verify:
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	cfssl version
	cfssljson --version
	kubectl version --client
	gcloud config configurations describe default
	vim --version
	tmux -V
	test -n "$(ETCD_VERSION)"
	test -n "$(KUBERNETES_VERSION)"
	test -n "$(RUNC_VERSION)"
	test -n "$(CONTAINERD_VERSION)"
	test -n "$(CRICTL_VERSION)"
	test -n "$(CNI_PLUGINS_VERSION)"
	test -n "$(PREFIX)"
	echo "Training Environment successfully verified"

.PHONY teardown:
teardown:
	./teardown.sh
	rm -rf secrets/*.pem
	rm -rf secrets/*.csr
	rm -rf secrets/*.kubeconfig
	rm -rf secrets/*.yaml