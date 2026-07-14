# Create a cluster backup

In this lab you will learn how to backup your Kubernetes Cluster via [restic](https://restic.net/).

The Backup consists of

- etcd data
- Kubernetes PKI

## Verify backup location

```bash
# verify your backup bucket exists
gcloud storage buckets describe gs://$S3_BUCKET/

# verify nothing is in your bucket yet
gcloud storage ls gs://$S3_BUCKET/
```

## Get the embedded restic backup addon

The restic backup addon is embedded into the kubeone binary. For adapting it to our needs we have to download it first.

```bash
# download the k1 source code
wget -P /tmp/ https://github.com/kubermatic/kubeone/archive/refs/tags/v${K1_VERSION}.zip

# unzip k1 source code
unzip /tmp/v${K1_VERSION}.zip -d /tmp/

# verify
ls -alh /tmp/kubeone-${K1_VERSION}

# create an addons directory
mkdir /training/addons/

# copy the restic addon
cp -r /tmp/kubeone-${K1_VERSION}/addons/backups-restic/ /training/addons/

# inspect the restic addon
ls -alh /training/addons
code /training/addons/backups-restic/README.md
code /training/addons/backups-restic/backups-restic.yaml
```

## Adapt the restic backup addon

The embedded restic backup addon is built for AWS. For making use of it within Google Cloud we have to make some adaptions.

```bash
# take a look at the restic backup addon tailored for google cloud
code /training/13_backup-cluster/backups-restic.yaml

# overwrite the aws addon with the gcp addon
cp /training/13_backup-cluster/backups-restic.yaml /training/addons/backups-restic/backups-restic.yaml
 
# we want to configure the addon via the file `/training/kubeone.yaml` therefore we need some infos

# create a restic password
cat /dev/urandom | tr -dc A-Za-z0-9 | head -c24

# get your S3 bucket
echo $S3_BUCKET

# get the gcp project id
echo $GCE_PROJECT
```

Add the backups restic addon to your file `/training/kubeone.yaml/.

```yaml
addons:
  enable: true
  path: /training/addons/
  addons:
    - name: backups-restic
      params:
        resticPassword: <FILL-IN-YOUR-RESTIC-PASSWORD>
        s3Bucket: "gs:<FILL-IN-YOUR-S3-BUCKET-NAME>:/cluster-backups"
        googleProjectId: "<FILL-IN-THE-GOOGLE-PROJECT>"
```

```bash
# apply
kubeone apply -t /training/tf_infra --verbose -y

# verify via kubeone
kubeone addons list -t /training/tf_infra | grep backups-restic

# verify successfull runs via cronjob
# note a backup will be done each 5 minutes
kubectl -n kube-system describe cronjob etcd-s3-backup

# verify if snapshot was built successfully
kubectl logs -f etcd-s3-backup-<TAB> -c snapshotter

# verify if snapshot was uploaded successfully
kubectl logs -f etcd-s3-backup-<TAB> -c uploader

# verify via gcloud
gcloud storage ls gs://$S3_BUCKET/cluster-backups

# take a look at the snapshots via gcloud
gcloud storage ls gs://$S3_BUCKET/cluster-backups/snapshots
```
