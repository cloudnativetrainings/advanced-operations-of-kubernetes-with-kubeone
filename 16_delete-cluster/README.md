# Bonus Topics

In this lab you will learn how to destroy the cluster and release the provisioned infrastructure.

```bash
# TODO del storage bucket for velero bucket
# TODO del lb service from nginx => helm delete $(helm ls --short)
# TODO del DNS entries
# gcloud dns record-sets transaction start --zone=ZONE_NAME
# gcloud dns record-sets transaction remove --name=RECORD_NAME --type=RECORD_TYPE --ttl=TTL --zone=ZONE_NAME
# gcloud dns record-sets transaction execute --zone=ZONE_NAME
 kubectl -n kube-system scale md --replicas=0 --all
# TODO wait until mds are scaled down => or do I need it at all???
 kubeone reset kubeone.yaml -t /training/tf_infra -y
 terraform -chdir=/training/tf_infra destroy -auto-approve
 gcloud compute instances list --format json | jq length
```
