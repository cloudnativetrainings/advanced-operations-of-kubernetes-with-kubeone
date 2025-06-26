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

mkdir -p /training/.secrets && cd /training/.secrets
gcloud iam service-accounts keys create --iam-account $GCP_SERVICE_ACCOUNT_ID k8c-cluster-provisioner-sa-key.json

echo "export GOOGLE_CREDENTIALS='$(cat /training/k8c-cluster-provisioner-sa-key.json)'" >> $TRAINING_DIR/.trainingrc
``` 
-->
