# Backup Kubernetes Resources

In this lab you will learn how to backup Kubernetes resources via [velero](https://github.com/heptio/velero).

## Prerequisites

In order to create a backup you have to create a storage bucket in GCE.

>**NOTE:**
>For production you should create a velero specific GCE ServiceAccount, for security reasons.

```bash
# verify velero is installed
velero version --client-only

# create a storage bucket in GCE
gcloud storage buckets create gs://k1-backup-bucket-$TRAINEE_NAME --default-storage-class=STANDARD

# verify
gcloud storage buckets describe gs://k1-backup-bucket-$TRAINEE_NAME

# install velero into your kubernetes cluster
velero install \
  --provider gcp \
  --plugins velero/velero-plugin-for-gcp:v1.12.1 \
  --bucket k1-backup-bucket-$TRAINEE_NAME \
  --velero-pod-cpu-request 250m \
  --secret-file /training/.secrets/gcloud-service-account.json

# switch to the namespace `velero`
kubens velero

# verify velero pods are running
kubectl get pods

# this is how velero gets its permissions to write to the GCE storage bucket
kubectl get secret -n velero cloud-credentials -o jsonpath='{.data.cloud}' | base64 --decode

# verify the backup storage location, it has to be in phase `Available`
kubectl get backupstoragelocations.velero.io default 
```

## Create a backup

```bash
# create the backup
velero backup create k1-backup

# get infos about the backup
velero backup describe k1-backup

# verify backup via kubectl
kubectl get backups

# verify backup via gsutil
gsutil ls -r gs://k1-backup-bucket-$TRAINEE_NAME
```

## Do wrong things

For being able to verify your backup restore worked well you will delete the whole namespace `my-app`.

```bash
# verify namespace `my-app` exists
kubens

# verify the app is still running, visit it in your browser
echo https://$DOMAIN

# delete the namespace `my-app`
kubectl delete namespace my-app

# verify namespace `my-app` has been deleted
kubens

# verify the app is not working anymore
echo https://$DOMAIN
```

## Restore your backup

```bash
velero restore create --from-backup k1-backup

# verify namespace `my-app` exists again
kubens

# verify the app is running again, visit it in your browser
echo https://$DOMAIN
```
