# Terraform

In this lab you will learn how to make use of terraform for providing the needed resources.

## Copy terraform scripts from the k1 directory

```bash
cp /training/kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/*.tf /training/tf_infra
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
terraform -chdir=/training/tf_infra init
```

## Get a plan of the resources to be created

> **Note**
> You will get error messages concerning unset terraform variables.

```bash
# get the plan of resources to be created
terraform -chdir=/training/tf_infra plan
```

### Set the terraform variables

Configure terraform via the file `/training/tf_infra/terraform.tfvars`

```bash
# get the value for the terraform input variable `project`
echo $GCE_PROJECT

# get the value for the terraform input variable `cluster_name`
echo $TRAINEE_NAME-cluster
```

Here is an example for the file `/training/tf_infra/terraform.tfvars`:

```hcl
# file /training/tf_infra/terraform.tfvars
project                                 = "my-gce-project"
cluster_name                            = "my-cluster"
region                                  = "europe-west3"
ssh_public_key_file                     = "/training/.secrets/gce.pub"
ssh_private_key_file                    = "/training/.secrets/gce"
control_plane_vm_count                  = 1
control_plane_target_pool_members_count = 1
initial_machinedeployment_replicas      = 1
```

>**HINT:**
>Terraform also allows to set this variables via environment variables. Eg you can set the value of the terraform input variable named `cluster_name` via `export TF_VAR_cluster_name=my-cluster`.
>You can find more details about this terraform feature in the the [terraform documentation](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name).

You can find more details about terraform configuration possibilities in the file [/training/kubeone_1.10.0_linux_amd64/examples/terraform/gce/](../kubeone_1.10.0_linux_amd64/examples/terraform/gce/README.md) in the section `Inputs`.

### Re-run `terraform plan`

```bash
# get the plan of resources to be created
terraform -chdir=/training/tf_infra plan
```

You get a list of all resources which terraform intends to create.

## Create resources

```bash
# provision the needed resources via terraform
terraform -chdir=/training/tf_infra apply

# verify the vm via gcloud
gcloud compute instances list

# verify the created resources via terraform
terraform -chdir=/training/tf_infra output
```
