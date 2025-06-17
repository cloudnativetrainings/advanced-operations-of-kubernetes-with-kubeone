# Terraform

In this lab you will learn how to make use of terraform for providing the needed infrastructure.

## Copy terraform scripts from the k1 directory

```bash
cp ./kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf .
```

<!-- # terraform.tfvars
# TODO clustername
# TODO project id -->

## Init the terraform environment

For being able to run terrafrom you have to init the environment. For example the needed provider plugins have to be downloaded.

You can find the provider configuration in the file 'main.tf'

```tf
provider "google" {
  region  = var.region
  project = var.project
}
```

```bash
# init the terraform environment
terraform init
```

## Get a plan of the resources to be created

> Note this will fail due to terraform does not know your GCP credentials now.

> Note the parameter `-var=control_plane_target_pool_members_count=1` is only needed at GCP.

```bash
terraform plan -var=control_plane_target_pool_members_count=1
```

You will get the following error message.

```log
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Attempted to load application default credentials since neither `credentials` nor `access_token` was set in the provider block.  No credentials loaded. To use your gcloud credentials, run 'gcloud auth application-default login'.  Original error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.
│ 
│   with provider["registry.terraform.io/hashicorp/google"],
│   on main.tf line 17, in provider "google":
│   17: provider "google" {
```

### Configure your gcloud service account

Copy your file `gcloud-service-account.json` into your github codespaces workspace.

<!-- TODO install gcloud!!! -->
<!-- # TODO PROJECT-ID -->
<!-- TODO move ssh towards the error message -->

```bash
gcloud auth activate-service-account --key-file=./gcloud-service-account.json
gcloud config set project k1-codespaces
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a
```

### Re-run `terraform plan`

```bash
terraform plan -var=control_plane_target_pool_members_count=1
```




<!-- #------------------------------------------------TODO

```bash

terraform apply -var=control_plane_target_pool_members_count=1 -auto-approve

terraform output -json > tf.json

kubeone apply -m /workspaces/kubermatic-kubernetes-platform-administration/kubeone.yaml -t tf.json
terraform apply

export KUBECONFIG=/workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig

``` -->
