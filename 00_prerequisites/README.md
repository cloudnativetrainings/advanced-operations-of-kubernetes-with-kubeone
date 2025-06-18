# Prerequisites

In this lab youe will learn how to to install KubeOne on your jump host.

## Install KubeOne

<!-- TODO hint to official way of downloading k1 -->

```bash
# set the k1 version
K1_VERSION=1.10.0

# download the k1 release
curl -LO https://github.com/kubermatic/kubeone/releases/download/v${K1_VERSION}/kubeone_${K1_VERSION}_linux_amd64.zip 

# unzip k1 release
unzip kubeone_${K1_VERSION}_linux_amd64.zip -d ./kubeone_${K1_VERSION}_linux_amd64

# copy k1 into directory within `$PATH`
cp ./kubeone_${K1_VERSION}_linux_amd64/kubeone /usr/local/bin

# verify k1 installation
kubeone version

# add k1 completion to your environment
echo 'source <(kubeone completion bash)' | tee -a /root/.trainingrc 

# persist the k1 version into an environment variable
echo "export K1_VERSION=${K1_VERSION}" | tee -a /root/.trainingrc
```

## GCloud Auth

 <!-- TODO -->
### Authorization

* roles/compute.admin
* roles/iam.serviceAccountUser

### Authentication

File `gcloud-service-account.json`

```json
{
  "type": "service_account",
  "project_id": "<PROJECT-ID>",
  "private_key_id": "<PRIVATE-KEY-ID>",
  "private_key": "<PRIVATE-KEY>",
  "client_email": "<NAME>@<PROJECT-ID>.iam.gserviceaccount.com",
  "client_id": "<CLIENT-ID>",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "<CLIENT-X509-CERT-URL>",
  "universe_domain": "googleapis.com"
}
```
