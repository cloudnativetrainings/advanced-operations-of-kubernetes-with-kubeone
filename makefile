.PHONY verify:
verify:
	test -f /root/.trainingrc
	grep "source /root/.trainingrc" /root/.bashrc
	kubectl version --client
	gcloud version
	terraform version
	kubectx
	test -n "$(GCE_PROJECT)" 
	test -n "$(TRAINEE_NAME)" 
	test -n "$(DOMAIN)" 
# TODO	kubens => failing due no cluster yet
	test -n "$(K8S_VERSION)" 
	test -n "$(TF_VERSION)" 
	test -e /training/.secrets/gce
# TODO ensure that is the right ssh key - ssh-add -l | grep "$(ssh-keygen -lf .secrets/gce)"
	test -e /training/.secrets/gcloud-service-account.json 
# TODO test -v $(GOOGLE_CREDENTIALS)
# TODO verify gcp sa permissions
	echo "Training Environment successfully verified"
	
.PHONY scale-down:
scale-down: 
	kubectl -n kube-system scale md --replicas=1 --all
# TODO scale masters

.PHONY scale-up:
scale-up: 
	kubectl -n kube-system scale md --replicas=3 --all
# TODO scale masters

.PHONY teardown:
teardown:
	kubectl -n kube-system scale md --replicas=0 --all
# TODO wait until mds are scaled down => or do I need it at all???
	kubeone reset kubeone.yaml -t /training/tf_infra -y
	terraform -chdir=/training/tf_infra destroy -auto-approve
	gcloud compute instances list --format json | jq length
