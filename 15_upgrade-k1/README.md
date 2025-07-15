# Upgrade KubeOne

In this lab you will learn how to upgrade kubeone. We will upgrade kubeone from version 1.10.0 to version 1.11.0.

- You can find information about the available versions of kubeone on the [releases page](https://github.com/kubermatic/kubeone/releases).
- Ensure the new version still supports the running kubernetes version. You can find the supported versions in the [kubeone documentation](https://docs.kubermatic.com/kubeone/v1.10/architecture/compatibility/supported-versions/).

```bash
# verify the current kubeone version
kubeone version

# set the new k1 version
NEW_K1_VERSION=1.11.0

# download the k1 release
wget -P /tmp/ https://github.com/kubermatic/kubeone/releases/download/v${NEW_K1_VERSION}/kubeone_${NEW_K1_VERSION}_linux_amd64.zip

# unzip k1 release
unzip /tmp/kubeone_${NEW_K1_VERSION}_linux_amd64.zip -d /training/kubeone_${NEW_K1_VERSION}_linux_amd64

# copy k1 into directory within `$PATH`
cp /training/kubeone_${NEW_K1_VERSION}_linux_amd64/kubeone /usr/local/bin

# verify the new version of kubeone
kubeone version

# ensure environment variable also gets an update
sed -i "s/K1_VERSION=1.10.0$/K1_VERSION=${NEW_K1_VERSION}/g" /root/.trainingrc
source /root/.trainingrc
echo $K1_VERSION

# verify via status of kubeone
kubeone status -t /training/tf_infra

# re-run kubeone apply with the new kubeone version, no changes to be expected
kubeone apply -t /training/tf_infra -y
```
