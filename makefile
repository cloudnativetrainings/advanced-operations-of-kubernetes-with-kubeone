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

.PHONY verify-preps:
verify-preps: verify
	kubeone version
	test -n "$(K1_VERSION)"
	test -e ./gcloud-service-account.json || echo "file not found"
	echo "Training Preps successfully verified"

# TODO test -v $(GOOGLE_CREDENTIALS)

.PHONY scale-down:
scale-down: 
	kubectl scale md --replicas=1 --all --all-namespaces
# TODO scale masters

.PHONY scale-up:
scale-up: 
	kubectl scale md --replicas=3 --all --all-namespaces
# TODO scale masters

.PHONY teardown:
teardown:
	kubectl scale md --replicas=0 --all --all-namespaces
# TODO wait until mds are scaled down => or do I need it at all???
	kubeone reset --manifest kubeone.yaml -t tf.json -y
	terraform destroy -auto-approve
	gcloud compute instances list --format json | jq length
