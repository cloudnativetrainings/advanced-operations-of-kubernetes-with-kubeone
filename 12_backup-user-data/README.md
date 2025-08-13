# Backup Kubernetes Resources

In this lab you will learn how to backup Kubernetes resources via [velero](https://github.com/heptio/velero).

You will restore Kubernetes Objects and also a PersitentVolume.

## Prerequisites

```bash
# deploy a storageclass
kubectl apply -f /training/12_backup-user-data/storageclass.yaml 
```

Adapt the application so it is persisting metainfo into a disk provided by GCE.

```yaml
  - releaseName: my-app
    chart: my-app
    chartURL: my-app/
    namespace: my-app
    version: 1.0.0
    values:
      - inline:
          color: lightblue
          message: "Hello from the app inside the k1 k8s cluster via custom addon"
          domain: "hubert-test.k1.fourdata.cloud-native.training"
          persistMetaInfo: true     # <= add this line
          replicas: 1               # <= add this line
```

```bash
# apply your changes
kubeone apply -t /training/tf_infra --verbose

# view the metainfo the application is persisting
kubectl exec -it deploy/my-app -- cat /app/data/metainfo.txt
```

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
velero backup create k1-backup-user-data --include-namespaces=my-app

# get the logs of the backup creation
velero backup logs k1-backup-user-data

# get infos about the backup
velero backup describe k1-backup-user-data

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

# delete data
kubectl delete pv <NAME-OF-PV>

# verify namespace `my-app` has been deleted
kubens

# verify pv has been deleted
kubectl get pv

# verify the app is not working anymore
echo https://$DOMAIN
```

## Restore your backup

```bash
# restore from previously created backup
velero restore create --from-backup k1-backup-user-data

# wait until restore of resources has finished
velero restore describe k1-backup-user-data-XXXXX | grep -A3 Phase

# verify pod is in running state again, which may take some time due to restored PV has to be bound to worker node which is running the new pod
kubectl describe pod -l app=my-app

# verify the app is running again, visit it in your browser
echo https://$DOMAIN

# get the first line of the file metainfo.txt
kubectl exec -it deploy/my-app -- head -1 /app/data/metainfo.txt

# get the last line of the file metainfo.txt
kubectl exec -it deploy/my-app -- tail -1 /app/data/metainfo.txt

# => note that the metainfo of the deleted pod is still available in the file metatinfo.txt
```

>**NOTE:**
>If you get into the situation that a PV is in state `RELEASED` you have to bring it into the state `AVAILABLE` before it can be bound to a worker node again. See the [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recovering-from-failure-when-expanding-volumes) for details.
