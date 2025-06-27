# Additional installed Components

Besides providing a vanilla Kubernetes cluster KubeOne takes care about some other things. This is done via the Addon mechanism. In this lab you will learn about embedded Addons. Creating custom Addons will be covered in a later lab.

## What got installed additionally?

Kubeone installs, besides the core Kubernetes components, some additional components by default.

Via adapting the kubeone manifest file `kubeone.yaml` you can change the installed components to your needs. Via `kubeone config print --full` you can see more informations about overriding the defaults.

### Container Runtime

Containerd gets installed by default

```bash
# verify
kubectl get nodes -o wide
```

### CNI Plugin

By default canal gets installed. Other CNI plugins are also supported. Take a look at the section `cni:` via `kubeone config print --full`.

```bash
# verify
kubectl -n kube-system get pods | grep canal
```

### Cloud Controller Manager

Depending on the provider you have chosen, the cloud controller manager got installed.

```bash
# verify
kubectl -n kube-system get pods | grep cloud-controller-manager
```

### Metrics-Server

For collecting and exposing metrics from Kubelets.

```bash
# verify
kubectl -n kube-system get pods | grep metrics-server

# eg you can do the following with the metrics-server installed into your cluster
kubectl top nodes
```

### NodeLocalDNS

For improving cluster performance on DNS queries NodeLocalDns got installed.

```bash
# verify
kubectl -n kube-system get pods | grep node-local-dns
```

### Machine Controller

For managing Worker Nodes.

```bash
# verify
kubectl -n kube-system get pods | grep machine-controller
```

## How does this work?

Via embedded addons.

Kubeone has a built in addons mechanism. Some of the addons are installed by default, for providing a fully working Kubernetes cluster. You can also make use of this mechanism for providing your own addons, as we will do in a later lab.

```bash
# list all embedded addons and their status
kubeone addons list -t /training/tf_infra
```

Those addons are embedded, so they are part of the kubeone binary. You can find the manifests of those embedded addons in [/training/kubeone_1.10.0_linux_amd64/addons/](../kubeone_1.10.0_linux_amd64/addons/).

Further information about addons you can find in the [kubeone docu](https://docs.kubermatic.com/kubeone/main/guides/addons/).
