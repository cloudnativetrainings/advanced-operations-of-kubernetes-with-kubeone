# Bonus Topics

In this lab you will learn how to destroy the cluster and release the provisioned infrastructure.

```bash
# reset the cluster
kubeone reset -t /training/tf_infra

# verify all worker nodes have been deleted
gcloud compute instances list

# destroy the infrastructure provided via terraform
terraform -chdir=/training/tf_infra destroy

# verify no vms are running
gcloud compute instances list

# delete the gce DNS entry
gcloud dns record-sets transaction start --zone $DNS_ZONE_NAME
gcloud dns record-sets transaction remove --zone $DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $INGRESS_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME
gcloud dns record-sets list --zone $DNS_ZONE_NAME

# delete the gce storage bucket
gcloud storage rm --recursive gs://k1-backup-bucket-$TRAINEE_NAME
```
