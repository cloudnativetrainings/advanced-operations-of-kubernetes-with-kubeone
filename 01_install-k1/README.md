# Install KubeOne

In this lab you will install kubeone.

> **NOTE:**
> To get the latest release of kubeone you can simply do `curl -sfL https://get.kubeone.io | sh`. For the training we will not use the latest release for being able to do a kubeone update.

> You can find more details about installing kubeone in the [kubeone documentation](<https://docs.kubermatic.com/kubeone/main/getting-kubeone/>).

```bash
# set the k1 version
export KUBEONE_VERSION=1.14.2

# download the k1 release
curl -sfL https://get.kubeone.io | sh

# verify k1 installation
kubeone version

# add k1 completion to your environment
echo 'source <(kubeone completion zsh)' | tee -a /root/.trainingrc

# persist the k1 version into an environment variable
echo "export KUBEONE_VERSION=${KUBEONE_VERSION}" | tee -a /root/.trainingrc
```
