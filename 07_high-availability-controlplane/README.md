# High Availability Control Plane

In this lab you will scale the control plane nodes and you will ensure these nodes are running in different zones within the gcp region.

## Provision additional vms via terraform

Increase the number of vms in the terraform configuration file `/training/tf_infra/terraform.tfvars`.

```hcl
control_plane_vm_count                  = 3      # <= change this value from 1 to 3
control_plane_target_pool_members_count = 1      # <= do not change this value
```

> **NOTE:**
> Due to gcp internals we cannot change the value of `control_plane_target_pool_members_count` yet. This will be done in a later step.

```bash
# provision the additional vms via terraform
terraform -chdir=/training/tf_infra apply
```

```bash
# verify the new vms are in different zones
gcloud compute instances list
```

## Add the additional vms to the Kubernetes cluster via kubeone

```bash
# add the additional vms to the Kubernetes cluster
kubeone apply -t /training/tf_infra --verbose
```

```bash
# verify via kubectl
kubectl get nodes
```

```bash
# verify via ui
kubeone ui -t /training/tf_infra --port 8081
```

### Fixing the LoadBalancer Issue on GCE

> **NOTE:**
> This only has to be done in GCE

The LoadBalancer in front of the api-server only considers the first created control plane node.

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

Increase the number of pool members in the terraform configuration file `/training/tf_infra/terraform.tfvars`.

```hcl
control_plane_vm_count                  = 3
control_plane_target_pool_members_count = 3      # <= change this value from 1 to 3
```

```bash
# provision the additional vms via terraform
terraform -chdir=/training/tf_infra apply
```

```bash
# verify the instances of the pool
gcloud compute target-pools describe <CLUSTER-NAME>-control-plane
```

```bash
# verify via kubeone
kubeone status -t /training/tf_infra
```

```bash
# verify via ui
kubeone ui -t /training/tf_infra --port 8081
```
