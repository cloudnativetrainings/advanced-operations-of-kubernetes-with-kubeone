# Teardown

In this lab you will learn how to destroy the cluster and release the provisioned infrastructure.

```bash
# reset the cluster
kubeone reset -t /training/tf_infra --remove-lb-services --remove-volumes --remove-binaries
```

```bash
# verify all worker nodes have been deleted
gcloud compute instances list
```

```bash
# destroy the infrastructure provided via terraform
terraform -chdir=/training/tf_infra destroy
```

```bash
# verify no vms are running
gcloud compute instances list
```

```bash
# delete the gcp DNS entry
gcloud dns record-sets delete $DOMAIN. --type=A --zone $DNS_ZONE_NAME
gcloud dns record-sets list --zone $DNS_ZONE_NAME
```

```bash
# delete the gcp storage bucket
gcloud storage rm --recursive gs://$S3_BUCKET
gcloud storage buckets list
```
