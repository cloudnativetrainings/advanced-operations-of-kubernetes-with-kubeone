# Upgrade KubeOne

In this lab you will learn how to upgrade kubeone. We will upgrade kubeone from version `1.14.2` to version `1.14.3`.

- You can find information about the available versions of kubeone on the [releases page](https://github.com/kubermatic/kubeone/releases).
- Ensure the new version still supports the running Kubernetes version. You can find the supported versions in the [kubeone documentation](https://docs.kubermatic.com/kubeone/main/architecture/compatibility/supported-versions/).

```bash
# verify the current kubeone version
kubeone version
```

```bash
# set the new k1 version
export KUBEONE_VERSION=1.14.3
```

```bash
# download and install the new k1 release
curl -sfL https://get.kubeone.io | sh
```

```bash
# verify k1 installation
kubeone version
```

```bash
# ensure environment variable also gets an update
sed -i "s/KUBEONE_VERSION=1.14.2$/KUBEONE_VERSION=${KUBEONE_VERSION}/g" /root/.trainingrc
source /root/.trainingrc
echo $KUBEONE_VERSION
```

```bash
# verify via status of kubeone
kubeone status -t /training/tf_infra
```

```bash
# mv the file `/training/tf_infra/terraform.tfvars` to somewhere else
mv /training/tf_infra/terraform.tfvars /training
```

```bash
# re-create the tf files
kubeone init --provider gce --cluster-name $TRAINEE_NAME-cluster --path /training/tf_infra
```

```bash
# remove the duplicate kubeone.yaml again, for not getting confused
rm /training/tf_infra/kubeone.yaml
```

```bash
# mv the file `/training/tf_infra/terraform.tfvars` to the directory `/training/tf_infra/` again
mv /training/terraform.tfvars /training/tf_infra/
```

>**NOTE:**
>Depending on your intended version jump different components can get upgraded. Please check [releases page](https://github.com/kubermatic/kubeone/releases) for details.

```bash
# re-run kubeone apply with the new kubeone version, no changes to be expected
kubeone apply -t /training/tf_infra -y
```

```bash
# verify via status of kubeone
kubeone status -t /training/tf_infra
```
