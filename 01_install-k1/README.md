# Install KubeOne

In this lab you will install kubeone.

> **NOTE:**
> To get the latest release of kubeone you can simply do `curl -sfL https://get.kubeone.io | sh`. For the training we will not use the latest relase for being able to do a kubeone update.
> You can find more details about installing kubeone in the [kubeone docu](<https://docs.kubermatic.com/kubeone/main/getting-kubeone/>).

```bash
# set the k1 version
K1_VERSION=1.10.0

# download the k1 release
wget -P /tmp/ https://github.com/kubermatic/kubeone/releases/download/v${K1_VERSION}/kubeone_${K1_VERSION}_linux_amd64.zip

# unzip k1 release
unzip /tmp/kubeone_${K1_VERSION}_linux_amd64.zip -d /training/kubeone_${K1_VERSION}_linux_amd64

# copy k1 into directory within `$PATH`
cp /training/kubeone_${K1_VERSION}_linux_amd64/kubeone /usr/local/bin

# verify k1 installation
kubeone version

# add k1 completion to your environment
echo 'source <(kubeone completion bash)' | tee -a /root/.trainingrc 

# persist the k1 version into an environment variable
echo "export K1_VERSION=${K1_VERSION}" | tee -a /root/.trainingrc

# ensure k1 version is set in your current bash
source /root/.trainingrc
```
