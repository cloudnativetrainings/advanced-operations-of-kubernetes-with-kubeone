# Low-Ability Cluster

In this lab you will create a kubernetes cluster with a single controlplane node and a single worker node.

<!-- TODO inspect kubeone.yaml -->

<!-- TODO link to https://docs.kubermatic.com/kubeone/main/architecture/compatibility/supported-versions/ -->

<!-- TODO note that tf.json could also be provided in kubeone.yaml -->

<!-- TODO k1 usage
  -m, --manifest string                 Path to the KubeOne config (default "./kubeone.yaml")
  -t, --tfjson terraform output -json   Source for terraform output in JSON - to read from stdin. If path is a file, contents will be used. If path is a dictionary, terraform output -json is executed in this path
 -->
```bash
# install control plane components on the control plane nodes
kubeone apply -m /training/kubeone.yaml -t /training/tf_infra/tf.json --verbose
```

## Verify Kubernetes Cluster

<!-- # TODO cluster name -->
```bash
# verify via kubeone
kubeone status -t /training/tf_infra -m /training/kubeone.yaml

# download the kubeconfig and make it your default kubeconfig
# note kubeone also downloaded the kubeconfig automaticaly (`/training/k1-training-kubeconfig`)
mkdir -p /root/.kube/
kubeone kubeconfig -t /training/tf_infra -m /training/kubeone.yaml > /root/.kube/config

# verify the control plane node and the worker nodes are ready
kubectl get nodes

# verify the pods in the namespace `kube-system` are in state `Running`
kubectl -n kube-system get pod 
```

## Installed Kubernetes AddOns by Kubeone

```bash

kubeone addons list -t /training/tf_infra -m /training/kubeone.yaml

kubeone ui -t /training/tf_infra -m /training/kubeone.yaml


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

```
