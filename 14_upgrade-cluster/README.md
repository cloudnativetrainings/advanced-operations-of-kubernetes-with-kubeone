# Upgrading your Kubernetes Cluster

In this lab you will learn to upgrade your Kubernetes Cluster from version 1.32.4 to 1.32.5.

## Prerequisites

>**IMPORTANT:**
> For security reasons you have to upgrade your Kubernetes Clusters. As a side effect, also the certificates which enable secure communication between the control plane components will get renewed.

- Check available Kubernetes Releases on the [kubernetes release page](https://kubernetes.io/releases/)
- **ALWAYS** read the changelogs of the new releases before upgrading your cluster. Ensure your deployed resources will not get into troubles due to breaking changes of the new release.
- Please respect the [kubernetes version skew policy](https://kubernetes.io/releases/version-skew-policy/#supported-versions) on doing upgrades.
- Verify your kubeone version supports the kubernetes version you want to upgrade to in the [kubeone documentation](https://docs.kubermatic.com/kubeone/main/architecture/compatibility/supported-versions/).

## Upgrade kubectl

```bash
# verify your current version 1.32.4
kubectl version

# upgrade kubectl 
NEW_K8S_VERSION=1.32.5
curl -LO https://dl.k8s.io/release/v${NEW_K8S_VERSION}/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# verify your new version 1.32.5 got installed
kubectl version

# ensure environment variable also gets an update
sed -i "s/K8S_VERSION=1.32.4$/K8S_VERSION=${NEW_K8S_VERSION}/g" /root/.trainingrc
source /root/.trainingrc
echo $K8S_VERSION
```

## Upgrade the control plane nodes

>**NOTE:**
>Although kubeone supports also upgrading the worker nodes via the flag `--upgrade-machine-deployments` we will do this in a later step.

The control plane nodes will get the components updated to the new version. The control plane nodes will **NOT** get replaced by new VMs.

Change the Kubernetes Version in the kubeone manifest `/training/kubeone.yaml`

```yaml
apiVersion: kubeone.k8c.io/v1beta2
kind: KubeOneCluster
versions:
  kubernetes: "1.32.5" # <= change from 1.32.4 to 1.32.5
```

Trigger the upgrade

```bash
# verify your applications are up and running during the upgrade process in a different bash
[BASH-2] while true; do curl -I https://$DOMAIN; sleep 10s; done;

# trigger the upgrade of the control plane nodes
kubeone apply -t /training/tf_infra --verbose

# verify your control plane nodes got upgraded via kubectl
kubectl get nodes

# verify your control plane nodes got upgraded via kubeone
kubeone status -t /training/tf_infra/
```

## Upgrade the worker nodes

You can upgrade the worker nodes via the MachineDeployment manifests. The worker nodes will get replaced by new VMs.

Similar to update strategies of Kubernetes Deployments you can customize how the upgrade process of the worker nodes will happen. Take a look into the MachineDeployment manifests.

It is important that the running applications have enough resources during the upgrade process to ensure high availability of the applications.

```yaml
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

>**NOTE:**
>In this case we allow the MachineDeployment to provision an additional VM during the upgrade process.

```bash
# change the kubelet version in the machinedeployment manifests
sed -i "s/kubelet: 1.32.4$/kubelet: 1.32.5/g" /training/md-europe-west3-a.yaml

# watch the machinecontroller upgrading the worker nodes
[BASH-2] watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machine,nodes

# verify your applications are up and running during the upgrade process in a different bash
[BASH-3] while true; do curl -I https://$DOMAIN; sleep 10s; done;

# apply your change
kubectl apply -f /training/md-europe-west3-a.yaml

# get a minimalistic visual representation of your cluster
# note the ui is currently only in beta state
kubeone ui -t /training/tf_infra
```

>**NOTE:**
>As long your applications running on the worker nodes are `cloud-native` you should not experience any downtime of them.
