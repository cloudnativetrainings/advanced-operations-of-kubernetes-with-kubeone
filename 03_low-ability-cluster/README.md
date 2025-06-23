# Creating the Control Plane

In this lab you will setup the control plane of the kubernetes cluster.

```bash
# install control plane components on the control plane nodes
kubeone apply -m ./kubeone.yaml -t ./tf_infra/tf.json --verbose
```

## Verify Kubernetes cluster

<!-- # TODO cluster name -->
```bash
mkdir -p /root/.kube && cp ./k1-training-kubeconfig /root/.kube/config

kubectl get nodes
```

## TODO

ensure machinedeployment "k1-pool1" with 2 replica(s) exists
=> name of pool and name of kubeconfig

terraform apply
