# Prerequisites

In this training you will learn how to bootstrap Kubernetes Clusters via KubeOne from within a Github Codespaces (AKA jump host).

## Verify installed software

```bash
# verify kubectl is installed
kubectl version --client

# verify terraform is installed
terraform version
```

## Ensure SSH requirements

```bash
# create a directory for holding sensitive information
mkdir /training/.secrets

# create a ssh-key-pair for gcloud
ssh-keygen -q -N "" -t rsa -f /training/.secrets/google_compute_engine -C root

# ensure proper private key file permissions
chmod 400 /training/.secrets/google_compute_engine

# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /training/.secrets/google_compute_engine" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify agent is running and holds proper key
ssh-add -l | grep "$(ssh-keygen -lf /training/.secrets/google_compute_engine)"
```

## Configure gcloud

> **IMORTANT**
> Copy your file `gcloud-service-account.json` into your github codespaces workspace.
> You can drag and drop the file in the codespaces file explorer into the directory `.secrets`.

```bash
# persist the project id into an environment variable
echo "export GOOGLE_PROJECT=$(cat /training/.secrets/gcloud-service-account.json | jq .project_id)" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# activate gcloud account
gcloud auth activate-service-account --key-file=/training/.secrets/gcloud-service-account.json

# set the gcloud project
gcloud config set project $GOOGLE_PROJECT --quiet

# set the compute region and zone
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a

# verify your settings
gcloud config list

# persist the google credentials into an environment variable (needed by terraform and k1)
echo "export GOOGLE_CREDENTIALS='$(cat /training/.secrets/gcloud-service-account.json)'" >> /root/.trainingrc

# TODO verify the right permissions
```

## Verify your environment

```bash
# ensure all environment variables get set in your current bash
source /root/.trainingrc

make verify
```

<!-- TODO -->
<!-- 
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
-->
