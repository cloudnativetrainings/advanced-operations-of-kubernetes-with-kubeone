# High Availability Control Plane

In this lab you will scale the controlplane nodes and you will ensure these nodes are running in different zones within the GCE region.

## Provision additional vms via terraform

Increae the number of vms in the terraform configuration file `/training/tf_infra/terraform.tfvars`.

```hcl
control_plane_vm_count                  = 3      # <= change this value from 1 to 3
control_plane_target_pool_members_count = 1      # <= do not change this value
```

> **NOTE:**
> Due to GCE internas we cannot change the value of `control_plane_target_pool_members_count` yet. This will be done in a later step.

```bash
# provision the additional vms via terraform
terraform -chdir=/training/tf_infra apply

# verify the new vms are in different zones
gcloud compute instances list
```

## Add the additional vms to the Kubernetes cluster via kubeone

```bash
# add the additional vms to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose

# verify via kubectl
kubectl get nodes

# verify via ui
kubeone ui -t /training/tf_infra
```

### Fixing the LoadBalancer Issue on GCE

> **NOTE:**
> This only has to be done in GCE

The LoadBalancer in front of the api-server only considers the first created controlplane node.

#### The Problem

```bash
# show the loadbalancer
gcloud compute forwarding-rules list

# show the instances in the pool linked in the forwarding-rule
gcloud compute target-pools describe <CLUSTER-NAME>-control-plane
```

> **NOTE:**
> Only one instance is in the list.

#### The Solution

Increae the number of pool members in the terraform configuration file `/training/tf_infra/terraform.tfvars`.

```hcl
control_plane_vm_count                  = 3      
control_plane_target_pool_members_count = 3      # <= change this value from 1 to 3
```

```bash
# provision the additional vms via terraform
terraform -chdir=/training/tf_infra apply

# verify the instances of the pool
gcloud compute target-pools describe <CLUSTER-NAME>-control-plane

# verify via kubeone
kubeone status -t /training/tf_infra
```
