# Backup etcd

In this lab you will learn how to backup etcd via [restic](https://restic.net/).

```bash
velero install \
  --provider gcp \
  --plugins velero/velero-plugin-for-gcp:v1.12.1 \
  --bucket k1-backup-bucket-$TRAINEE_NAME \
  --velero-pod-cpu-request 250m \
  --secret-file /training/.secrets/gcloud-service-account.json
```

# 2. Restic Backup for etcd Snapshots

Next we want to create a dedicated backup for our etcd database in an automated way. So as reference, KubeOne already have a default addon for storing the etcd snapshots at a S3 Location, see [Restic backup addon](https://docs.kubermatic.com/kubeone/main/examples/addons-backup). Now we want to adjust it to use our GCP Storage Bucket.

The chapter folder already contains and template what have been adjusted to use GS bucket. If you compare the both files [`template.backups-restic.yaml`](./template.backups-restic.yaml) and [`backups-restic.yaml`](https://github.com/kubermatic/kubeone/raw/main/addons/backups-restic/backups-restic.yaml), you see that only minor adjustment has been needed. For more details how to configure Restic, see the [Restic Documentation - Preparing a new repository - Google Cloud Storage](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html#google-cloud-storage).
![restic_yaml_diff_s3_vs_gs](../.images/restic_yaml_diff_s3_vs_gs.png)

To prevent to manage Google Service Account credential secret, we can use the [KubeOne Addon Templating](https://docs.kubermatic.com/kubeone/main/guides/addons/#templating) and render the `.Credentials object` into a base64 encoded secret. At the KubeOne Go code, we can see the data constant what get used for credential rendering [`pkg/credentials/credentials.go`](https://github.com/kubermatic/kubeone/blob/c824810769d4ce55b3cfdc560b46b6563c8c509e/pkg/credentials/credentials.go). In our case, we use the `.Credentials.GOOGLE_CREDENTIALS` what is wrapped into the [`b64enc` sprig function](http://masterminds.github.io/sprig/encoding.html).

Now let's copy the template and adjust the needed `<<TODO_xxxx>>` parameters to our lab environment:

```bash
cd $TRAINING_DIR/src/gce

cp ../../10_addons-sc-and-restic-etcd-backup/template.backups-restic.yaml addons/gs.backups-restic.yaml
vim addons/gs.backups-restic.yaml
```

Adjust now the `<<TODO_xxxx>>` parameter:

- `<<TODO_RESTIC_PASSWORD>>`: some random string value, e.g. create a random string by: `cat /dev/urandom | tr -dc A-Za-z0-9 | head -c24`
- `<<TODO_GS_BUCKET_NAME>>`: you present gs bucket, check `gsutil ls`
- `<<TODO_BACKUP_FOLDER_NAME>>`: custom folder as backup location (get created), e.g. `etcd-snapshot-backup`
- `<<TODO_GOOGLE_PROJECT_ID>>`: your google project id, check `gcloud projects list`

Afterwards ensure no `TODO` is left and apply the new addon:

```bash
grep TODO addons/gs.backups-restic.yaml

kubeone apply -t ./tf-infra --verbose
```

You see the adjustments of the backup location, isn't hard and could be done a few changes of the restic environment variables. So let's now test, if we could see a cronjob and execute a test backup.

```bash
kubectl get cronjobs -n kube-system
```

```text
NAME             SCHEDULE     SUSPEND   ACTIVE   LAST SCHEDULE   AGE
etcd-gs-backup   @every 30m   False     0        <none>          9s
```

>As you see, every `30m` will automatic backup job be scheduled now.

To test now the backup create, we create a manual test job:

```bash
kubectl config set-context --current --namespace=kube-system
```

or

```bash
kcns kube-system
```

Create a job from the cronjob

```bash
kubectl create job --from cronjob/etcd-gs-backup test-etcd-backup
```

Check, if job got created and pod is running

```bash
kubectl get job,pod | grep test
```

```text
job.batch/test-etcd-backup   1/1           18s        79s
pod/test-etcd-backup-gg8gw                        0/1     Completed   0          79s
```

Check the logs of the backup pod

```bash
kubectl logs test-etcd-backup-gg8gw
```

See, if the bucket contains restic data

```
gsutil ls -r gs://k1-backup-bucket-${GCP_PROJECT_ID}/etcd-snapshot-backup
```

Alright, seems everything looks fine, and our cluster has automatic backup configured.

Jump > [**Home**](../README.md) | Previous > [**Velero Backup Process**](../09_backup_velero/README.md) | Next > [**KubeOne and Kubernetes Upgrade**](../11_kubeone_upgrade/README.md)
