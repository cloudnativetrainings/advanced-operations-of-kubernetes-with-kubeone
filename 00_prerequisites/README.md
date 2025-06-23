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

# ensure k1 version is set in your current shell
source ~/.trainingrc
```

## GCloud Auth

```bash
# persist the google credentials into an environment variable (needed by terraform and k1)
echo "export GOOGLE_CREDENTIALS='$(cat ./gcloud-service-account.json)'" >> /root/.trainingrc

# ensure google credentials are set in your current shell
source ~/.trainingrc

# TODO verify the right permissions
```

## Verify

```bash
make verify-preps
```

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

<!-- TODO move sa.json and ssh key into secrets folder? -->

<!-- TODO make it doable also via self service sa.json  - makefile??? -->

```bash
gcloud iam service-accounts create k1-service-account
gcloud iam service-accounts list

export GCP_SERVICE_ACCOUNT_ID=$(gcloud iam service-accounts list --format='value(email)' --filter='email~k1-service-account.*')
# e.g.: k1-service-account@student-XX-project.iam.gserviceaccount.com

# for avoiding problem with Google Cloud Shell on reconnects we persist this value also into our .trainingrc file
echo "export GCP_SERVICE_ACCOUNT_ID=$GCP_SERVICE_ACCOUNT_ID" >> $TRAINING_DIR/.trainingrc

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID --member serviceAccount:$GCP_SERVICE_ACCOUNT_ID --role='roles/compute.admin'
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID --member serviceAccount:$GCP_SERVICE_ACCOUNT_ID --role='roles/iam.serviceAccountUser'

# TODO make consistent with training-infra
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID --member serviceAccount:$GCP_SERVICE_ACCOUNT_ID --role='roles/viewer'
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID --member serviceAccount:$GCP_SERVICE_ACCOUNT_ID --role='roles/storage.admin'

mkdir -p ./.secrets && cd ./.secrets
gcloud iam service-accounts keys create --iam-account $GCP_SERVICE_ACCOUNT_ID k8c-cluster-provisioner-sa-key.json

echo "export GOOGLE_CREDENTIALS='$(cat ./k8c-cluster-provisioner-sa-key.json)'" >> $TRAINING_DIR/.trainingrc
```
