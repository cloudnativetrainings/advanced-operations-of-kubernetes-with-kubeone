# Creating the Control Plane

In this lab you will setup the control plane of the kubernetes cluster.

```bash
# install control plane components on the control plane nodes
kubeone apply -m kubeone.yaml -t tf.json


terraform apply

export KUBECONFIG=/workspaces/kubermatic-kubernetes-platform-administration/kubeone_1.9.1_linux_amd64/examples/terraform/gce/hubert-test-kubeconfig

```
