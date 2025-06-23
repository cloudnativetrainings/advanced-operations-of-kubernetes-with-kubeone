# Terraform

In this lab you will learn how to make use of terraform for providing the needed infrastructure.

## Copy terraform scripts from the k1 directory

```bash
cp ./kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf .
```

## Init the terraform environment

For being able to run terrafrom you have to init the environment. For example the needed provider plugins have to be downloaded.

You can find the provider configuration in the file 'versions.tf'

```terraform
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.27.0"
    }
  }
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

You will get the following error message concerning gcloud credentials.

### Configure gcloud

Copy your file `gcloud-service-account.json` into your github codespaces workspace.

```bash
# TODO auto approve

# activate gcloud account
gcloud auth activate-service-account --key-file=./gcloud-service-account.json

# set the gcloud project
gcloud config set project k1-codespaces

# set the compute region and zone
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a

# verify your settings
gcloud config list
```

### Set the terraform variables

Configure terraform via the file `terraform.tfvars`

```tfvars
project             = "<FILL-IN-YOUR-GOOGLE-PROJECT-ID>" # you can get the info via `gcloud config get project`
cluster_name        = "<FILL-IN-CLUSTER-NAME>"           # eg "k1-training"
region              = "europe-west3"
ssh_public_key_file = "/root/.ssh/google_compute_engine.pub"

```

> Note, if you prefer setting those via environment variables instead of a file, you can do so by

```bash
echo "export TF_VAR_project=${gcloud config get project}" | tee -a /root/.trainingrc
echo "export TF_VAR_cluster_name=k1-training" | tee -a /root/.trainingrc
echo "export TF_VAR_region=europe-west3" | tee -a /root/.trainingrc
echo "export TF_VAR_ssh_public_key_file="/root/.ssh/google_compute_engine.pub"| tee -a /root/.trainingrc

# ensure google credentials are set in your current shell
source ~/.trainingrc
```

### Re-run `terraform plan`

```bash
terraform plan -var=control_plane_target_pool_members_count=1
```

You get a list of all resources which terraform intends to create.

## Create resources

```bash
# provision the needed resources via terraform
terraform apply -var=control_plane_target_pool_members_count=1

# persist the information about the created resources into the file `tf.json`
terraform output -json > tf.json
```
