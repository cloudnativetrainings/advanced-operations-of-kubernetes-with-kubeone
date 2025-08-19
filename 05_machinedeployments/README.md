# MachineDeployments

In this lab you will learn how to manage worker nodes via MachineDeployments.

## Declarativity for the win

```bash
# take a look at the CRDs installed by the machinecontroller
kubectl api-resources | grep machine

# inspect the installed objects installed by the machinecontroller
kubectl -n kube-system get machinedeployment,machineset,machine

# get the tech details about the worker node
kubectl -n kube-system describe machine

# get the initial machineDeployment via kubeone
kubeone config machinedeployments -t /training/tf_infra > /training/md-initial.yaml
```

## Change the default MachineDeployment

The MachineDeployment allows you to manage worker nodes. Change the machineType of the machineDeployment in the file `/training/md-initial.yaml`

Change the machine type of the worker node

```yaml
machineType: n1-standard-2 # <= change the value to n1-standard-4
```

```bash
# apply your change
kubectl apply -f /training/md-initial.yaml
```

Watch the machinecontroller creating a new worker node and deleting the old one.

```bash
# watch the resources getting changed by machinecontroller
watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machine,node

# alternatively you can also watch the logs of machinecontroller
kubectl -n kube-system logs -f deployments/machine-controller

# verify
gcloud compute instances list
```

## The missing link from machinecontroller to a hyperscaler

The machinecontroller has to be able to scale machines up and down. For this it needs a proper GCE ServiceAccount.

```bash
# machinecontroller is using the credentials you have provided in a previous step
kubectl get secret -n kube-system kubeone-ccm-credentials -o jsonpath='{.data.GOOGLE_SERVICE_ACCOUNT}' | base64 -d
```

You can find further information about machinecontroller in the [kubeone docu](https://docs.kubermatic.com/kubeone/main/guides/machine-controller/)
