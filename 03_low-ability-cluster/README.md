# Low-Ability Cluster

In this lab you will create a kubernetes cluster with a single controlplane node and a single worker node.

## Working with kubeone

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

### Make use of kubeone config files

Most of the kubeone commands depend on the kubeone manifest file. You can teach a manifest to kubeone in 2 different ways.

```bash
# using the manifest file
kubeone <COMMAND> -m my-kubeone.yaml ...

# using the `kubeone.yaml` manifest file of the current directory
# => as long as you are in the directory `/training/` you can make use of this way
kubeone <COMMAND> ...
```

## Passing terraform outputs into kubeone

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
mkdir -p /root/.kube/
kubeone kubeconfig -t /training/tf_infra > /root/.kube/config

# verify the control plane node and the worker nodes are ready
kubectl get nodes

# verify the pods in the namespace `kube-system` are in state `Running`
kubectl -n kube-system get pod 
```

<!-- TODO stopped here -->

## Installed Kubernetes AddOns by Kubeone

```bash

kubeone addons list -t /training/tf_infra

kubeone ui -t /training/tf_infra


# check the resource needs of the pod (which indicates also metrics-server is running)
kubectl top pods

INFO[11:04:56 UTC] Applying addon coredns-pdb...                
INFO[11:04:58 UTC] Applying addon metrics-server...             
INFO[11:05:00 UTC] Applying addon cni-canal...                  
INFO[11:05:04 UTC] Applying addon nodelocaldns...               
INFO[11:05:07 UTC] Applying addon machinecontroller...          
INFO[11:05:15 UTC] Applying addon operating-system-manager...   
INFO[11:05:27 UTC] Applying addon csi-gcp-compute-persistent... 
INFO[11:05:32 UTC] Applying addon csi-external-snapshotter...   
INFO[11:05:36 UTC] Applying addon ccm-gcp...   

https://github.com/kubermatic/kubeone/tree/main/addons

https://docs.kubermatic.com/kubeone/main/guides/addons/


/training/kubeone_1.10.0_linux_amd64/addons

Default Configuration
By default, KubeOne installs the following components:

Container Runtime: containerd for Kubernetes 1.22+ clusters, otherwise Docker
CNI: Canal (based on Calico and Flannel)
Cilium, WeaveNet, and user-provided CNI are supported as an alternative
metrics-server for collecting and exposing metrics from Kubelets
NodeLocal DNSCache for caching DNS queries to improve the cluster performance
Kubermatic machine-controller, a Cluster-API based implementation for managing worker nodes
```
