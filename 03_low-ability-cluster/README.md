# Low-Ability Cluster

In this lab you will create a kubernetes cluster with a single controlplane node and a single worker node.

## Working with KubeOne

```bash
# getting help
kubeone help
```

## KubeOne manifests

You can find our cluster manifest in the file `kubeone.yaml`.

```bash
cat /training/kubeone.yaml
```

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: "1.32.4"  # <= the kubernetes version we will install
cloudProvider:
  gce: {}               # <= we will make use of gce resources
  external: true        # <= deploy the external CCM
  cloudConfig: |        # <= cloud provider specific configuration
    [global]
    regional = true
    multi-zone = true
    token-url = "nil"
```

### Kubernetes Version

Each kubeone version supports specific kubernetes versions. You can find all supported kubernetes versions in the [kubeone docu](https://docs.kubermatic.com/kubeone/main/architecture/compatibility/supported-versions/).

### Cloud Provider

You can find all suppored providers in the [kubeone docu](https://docs.kubermatic.com/kubeone/main/architecture/supported-providers/).

> **cloudConfig**:
> The cloud provider specific configuration. You can find details in the [kubeone source code](https://github.com/kubermatic/kubeone/blob/main/pkg/templates/machinecontroller/cloudprovider_specs.go#L73)

### Additional configuration possibilities

For getting a full picture of the configuration possibilities you can run the following command:

```bash
kubeone config print --full
```

### Use KubeOne Manifests

Most of the kubeone commands depend on the kubeone manifest file. You can teach a manifest to kubeone in 2 different ways.

```bash
# using the manifest file
kubeone <COMMAND> -m my-kubeone.yaml ...

# using the `kubeone.yaml` manifest file of the current directory
# => as long as you are in the directory `/training/` you can make use of this way
kubeone <COMMAND> ...
```

## Passing Terraform Outputs into KubeOne

Kubeone needs the information about the created resources. The most common way is to pass the terraform outputs into kubeone. For doing this, there are 2 different ways available:

### Explicitly, via a file created via terraform output

```bash
# create the terraform output file
terraform -chdir=/training/tf_infra output -json > /training/tf_infra/tf.json

# make use of this file
kubeone <COMMAND> -t /training/tf_infra/tf.json ...
```

### Implicit, via the terraform directory

You can also pass in the terraform directory. Kubeone will then automatically call `terraform output -json` in this directory to get the needed information.

```bash
kubeone <COMMAND> -t /training/tf_infra/ ...
```

### Without terraform

As an alternative, eg if you do not use terraform at all, you can configure the created resources also directly in the manifest file `kubeone.yaml`.

You can find details about this mechanism via `kubeone config print --full` in the section `controlPlane`:

```yaml
controlPlane:
  hosts:
  - publicAddress: '1.2.3.4'
    privateAddress: '172.18.0.1'
    ...
```

## Create your Kubernetes Cluster

Now, let's get real ;)

```bash
kubeone apply -t /training/tf_infra --verbose
```

## Verify your Kubernetes Cluster

```bash
# verify via kubeone
kubeone status -t /training/tf_infra

# download the kubeconfig and make it your default kubeconfig
# note kubeone also downloaded the kubeconfig automaticaly (`/training/k1-training-kubeconfig`)
mkdir /root/.kube/
kubeone kubeconfig -t /training/tf_infra > /root/.kube/config

# verify the control plane node and the worker nodes are ready
kubectl get nodes

# verify the pods in the namespace `kube-system` are in state `Running`
kubectl -n kube-system get pod 
```
