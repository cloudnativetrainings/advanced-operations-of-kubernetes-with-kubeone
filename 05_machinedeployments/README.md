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

# get all machinedeployments in the cluster
kubeone config machinedeployments -t /training/tf_infra > my-mds.yaml

# get a minimalistic visual representation of your cluster
# note the ui is currently only in beta state
kubeone ui -t /training/tf_infra
```

## Change the default MachineDeployment

The MachineDeployment allows you to manage worker nodes. Let's try this.

```bash
# edit the default machine deployment
kubectl -n kube-system edit md <MACHINE-DEPLOYMENT>
```

Change the machine type of the worker node

```yaml
machineType: n1-standard-2 # <= change the value to n1-standard-4
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
