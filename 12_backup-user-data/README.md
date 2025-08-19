# Backup Kubernetes Resources

In this lab you will learn how to backup Kubernetes resources via [velero](https://github.com/heptio/velero).

You will restore Kubernetes Objects and also a PersitentVolume.

## Prerequisites

### Change the MachineDeployments

For having enough resources for the following steps we have to adapt the MachineDeployments again.

```bash
# change the machine type from `n1-standard-2` to `n1-standard-1` in the machinedeployments manifests
sed -i "s/machineType: n1-standard-1$/machineType: n1-standard-4/g" /training/md-europe-west3-a.yaml

# apply the changed machinedeployment manifest
kubectl apply -f /training/md-europe-west3-a.yaml

# delete the other machinedeployment manifests
kubectl delete -f /training/md-europe-west3-b.yaml
kubectl delete -f /training/md-europe-west3-c.yaml
```

### Adapt the application

In the next step you will adapt the application to store metainfo into a PV. Therefore you have to create a StorageClass upfront.

```bash
# deploy a storageclass
kubectl apply -f /training/12_backup-user-data/storageclass.yaml 
```

Adapt the application via the file `/training/training-application-values.yaml`

```yaml
persistMetaInfo: false               # <= set this value to true

deployment:
  replicas: 1                        # <= set this value to 1 
```

```bash
# re-release your application
helm upgrade --install --atomic --debug \
  --namespace training-application --create-namespace training-application \
  oci://quay.io/kubermatic-labs/helm-charts/training-application:1.0.1 \
  -f /training/training-application-values.yaml

# view the metainfo the application is persisting
kubectl exec -it deploy/my-app -- cat /app/data/metainfo.txt

# verify the application now is using a PV
kubectl get pvc,pv
```

>**NOTE:**
>You will now experience downtimes of the application due to it snot `cloud-native` anymore.

### Setup velero

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
velero backup create k1-backup-user-data --include-namespaces=training-application

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

For being able to verify your backup restore worked well you will delete the whole namespace `training-application`.

```bash
# verify namespace `training-application` exists
kubens

# verify the app is still running
curl https://$DOMAIN

# delete the namespace `training-application`
kubectl delete namespace training-application

# delete data
kubectl delete pv <NAME-OF-PV>

# verify namespace `training-application` has been deleted
kubens

# verify pv has been deleted
kubectl get pv

# verify the app is not working anymore
curl https://$DOMAIN
```

## Restore your backup

```bash
# restore from previously created backup
velero restore create --from-backup k1-backup-user-data

# wait until restore of resources has finished
velero restore describe k1-backup-user-data-XXXXX | grep -A3 Phase

# verify pod is in running state again, which may take some time due to restored PV has to be bound to worker node which is running the new pod
kubectl describe pod -l app=my-app

# verify the app is running again
curl https://$DOMAIN

# get the first line of the file metainfo.txt
kubectl exec -it deploy/my-app -- head -1 /app/data/metainfo.txt

# get the last line of the file metainfo.txt
kubectl exec -it deploy/my-app -- tail -1 /app/data/metainfo.txt

# => note that the metainfo of the deleted pod is still available in the file metatinfo.txt
```

>**NOTE:**
>If you get into the situation that a PV is in state `RELEASED` you have to bring it into the state `AVAILABLE` before it can be bound to a worker node again. See the [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recovering-from-failure-when-expanding-volumes) for details.

## Clean-Up

For having no downtime in your application in the further labs we have to make it `cloud-native` again.

Adapt the application via the file `/training/training-application-values.yaml`

```yaml
persistMetaInfo: true                # <= set this value to false

deployment:
  replicas: 1                        # <= set this value to 3
```

```bash
# re-release your application
helm upgrade --install --atomic --debug \
  --namespace training-application --create-namespace training-application \
  oci://quay.io/kubermatic-labs/helm-charts/training-application:1.0.1 \
  -f /training/training-application-values.yaml

# delete the PV too
kubectl delete pv <NAME-OF-PV>
```
