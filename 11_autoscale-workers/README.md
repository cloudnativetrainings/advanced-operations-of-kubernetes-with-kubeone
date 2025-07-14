# Autoscale Worker Nodes

In this lab you will learn how to autoscale your worker nodes.

## Enable the kubeone embedded addon `cluster-autoscaler`

>**NOTE:**
>You can find further information about embedded addons in the [kubeone documentation](https://docs.kubermatic.com/kubeone/main/guides/addons/#activate-embedded-addons)

>**NOTE:**
>You can find the list of all available embedded addons in the [directory addons](../kubeone_1.10.0_linux_amd64/addons/)

Add the following to your kubone manifest file `/training/kubeone.yaml`:

```yaml
addons:
  enable: true
  addons:    
    - name: cluster-autoscaler
```

```bash
# add the releases to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose

# verify cluster-autoscaler is running
kubectl -n kube-system get deployments.apps cluster-autoscaler 
```

## Increase the resource needs for you application

```bash
# switch to the namespace `my-app`
kubens my-app

# scale up your application to 10 replicas
kubectl scale deployment my-app --replicas 10

# verify resource pressure
# note, that some pods are stuck in pending state due to resource pressure
kubectl get pods

# check the events for "Insufficient cpu"
kubectl get events | grep "Insufficient cpu"

# check the logs of the cluster-autoscaler
kubectl logs -n kube-system deployments/cluster-autoscaler | grep my-app
```

## Engage the ClusterAutoscaler on your MachineDeployments

The min and max number of worker nodes are managed via an annotation in your machinedeployment manifest files:

```yaml
kind: MachineDeployment
metadata:
  annotations:
    cluster.k8s.io/cluster-api-autoscaler-node-group-min-size: "1"
    cluster.k8s.io/cluster-api-autoscaler-node-group-max-size: "1" # <= change this to 3
```

```bash
# apply your changes
kubectl apply -f /training/md-europe-west3-a.yaml
kubectl apply -f /training/md-europe-west3-b.yaml
kubectl apply -f /training/md-europe-west3-c.yaml
```

## Watch the cluster-autoscaler in action

>**NOTE:**
>The cluster-autscaler takes some time to trigger changes.

```bash
# Open a new bash in Google Cloud Shell
# => with this we monitor auto-scale adding worker nodes
[BASH-2] watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machine,node

# Open a new bash in Google Cloud Shell
# => with this we monitor the pods getting into running state
[BASH-3] watch -n 1 kubectl get pods

# verify via cluster-autoscaler logs
kubectl -n kube-system logs deployments/cluster-autoscaler | grep Scale-up
```

## Scale your application down again

```bash
# scale down your application to 3 replicas
# => sooner, or later, also the worker nodes will get scaled down again
kubectl scale deployment my-app --replicas 3
```
