# Prerequisites

In this lab youe will learn how to to install KubeOne on your jump host.

## Install KubeOne

```bash
# set the k1 version
K1_VERSION=1.10.0

# download the k1 release
curl -LO https://github.com/kubermatic/kubeone/releases/download/v${K1_VERSION}/kubeone_${K1_VERSION}_linux_amd64.zip 

# unzip k1 release
unzip kubeone_${K1_VERSION}_linux_amd64.zip -d ./kubeone_${K1_VERSION}_linux_amd64

# copy k1 into directory within `$PATH`
cp /root/kubeone_${K1_VERSION}_linux_amd64/kubeone /usr/local/bin

# verify k1 installation
kubeone version

# add k1 completion to your environment
echo 'source <(kubeone completion bash)' | tee -a /root/.trainingrc 

# persist the k1 version into an environment variable
echo "export K1_VERSION=${K1_VERSION}" | tee -a /root/.trainingrc
```
