# Terraform

In this lab you will learn how to make use of terraform for providing the needed infrastructure.

## Copy terraform scripts from the k1 directory

```bash
cp /workspaces/advanced-operations-of-kubernetes-with-kubeone/kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf /workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra
```

## Init the terraform environment

For being able to run terrafrom you have to init the environment. For example the needed provider plugins have to be downloaded.

You can find the provider configuration in the file `tf_infra/versions.tf`

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
# init the terraform environment inside the tf_infra directory
terraform -chdir=/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra init
```

## Get a plan of the resources to be created

> **Note**
> You will get error messages concerning unset terraform variables.

```bash
# get the plan of resources to be created
terraform -chdir=/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra plan
```

### Set the terraform variables

Configure terraform via the file `/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra/terraform.tfvars`

> Note, if you prefer setting those via environment variables instead of a file, you can do so by

<!-- TODO -->
<!-- ```bash
echo "export TF_VAR_project=${gcloud config get project}" | tee -a /root/.trainingrc
echo "export TF_VAR_cluster_name=k1-training" | tee -a /root/.trainingrc
echo "export TF_VAR_region=europe-west3" | tee -a /root/.trainingrc
echo "export TF_VAR_ssh_public_key_file="/root/.ssh/google_compute_engine.pub"| tee -a /root/.trainingrc

# ensure google credentials are set in your current shell
source /root/.trainingrc
``` -->

### Re-run `terraform plan`

```bash
# get the plan of resources to be created
terraform -chdir=/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra plan
```

You get a list of all resources which terraform intends to create.

<!-- TODO hint to machine type and os type -->

<!-- TODO name clash => all resources have to be prefixed!!! flag cluster name -->

## Create resources

```bash
# provision the needed resources via terraform
terraform -chdir=/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra apply

# show all created vms
gcloud compute instances list

# persist the information about the created resources into the file `tf.json`
terraform -chdir=/workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra output -json > /workspaces/advanced-operations-of-kubernetes-with-kubeone/tf_infra/tf.json
```
