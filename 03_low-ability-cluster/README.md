# Low-Ability Cluster

In this lab you will create a kubernetes cluster with a single controlplane node and a single worker node.

<!-- TODO inspect kubeone.yaml -->

<!-- TODO link to https://docs.kubermatic.com/kubeone/main/architecture/compatibility/supported-versions/ -->

<!-- TODO note that tf.json could also be provided in kubeone.yaml -->
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
kubeone kubeconfig -t /training/tf_infra -m /training/kubeone.yaml > /root/.kube/config

# verify the control plane node and the worker nodes are ready
kubectl get nodes

# verify the pods in the namespace `kube-system` are in state `Running`
kubectl -n kube-system get pod 
```
