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
kubeone config machinedeployments -t /training/tf_infra > my-md.yaml
```

## The missing link from machinecontroller to a hyperscaler

```bash
# machinecontroller is using the credentials you have provided in a previous step
kubectl get secret -n kube-system kubeone-ccm-credentials -o jsonpath='{.data.GOOGLE_SERVICE_ACCOUNT}' | base64 -d
```
