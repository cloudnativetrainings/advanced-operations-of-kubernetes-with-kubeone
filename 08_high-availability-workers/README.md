# High Availability Worker Nodes

In this lab you will provision two additional nodes and ensure that they are running in different zones within the GCE region.

## Preperations

```bash
# switch to the namespace `kube-system`
kubens kub-system

# store the existing md into the file `md-europe-west3-a.yaml`
kubeone config machinedeployments -t tf_infra/ > /training/old-md.yaml
```

## Create the new MachineDeployment Manifests

```bash
# make copies of the old machinedeployment manifest `old-md.yaml`
cp /training/old-md.yaml /training/md-europe-west3-a.yaml
cp /training/old-md.yaml /training/md-europe-west3-b.yaml
cp /training/old-md.yaml /training/md-europe-west3-c.yaml

# change the names of the mds, assuming the name of the pool ends with `pool1`
sed -i "s/pool1$/europe-west3-a/g" /training/md-europe-west3-a.yaml
sed -i "s/pool1$/europe-west3-b/g" /training/md-europe-west3-b.yaml
sed -i "s/pool1$/europe-west3-c/g" /training/md-europe-west3-c.yaml

# change the zones of the mds
sed -i 's/europe-west3-a$/europe-west3-b/g' /training/md-europe-west3-b.yaml
sed -i 's/europe-west3-a$/europe-west3-c/g' /training/md-europe-west3-c.yaml

# verify
diff /training/md-europe-west3-a.yaml /training/md-europe-west3-b.yaml
diff /training/md-europe-west3-a.yaml /training/md-europe-west3-c.yaml
```

## Apply the new MachineDeployment Manifests to your Cluster

```bash
# apply the new md manifests
kubectl apply -f /training/md-europe-west3-a.yaml
kubectl apply -f /training/md-europe-west3-b.yaml
kubectl apply -f /training/md-europe-west3-c.yaml

# delete the old md
kubectl delete -f /training/old-md.yaml

# watch the resources getting changed by machinecontroller
watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machine,node

# verify via gcloud
gcloud compute instances list

# verify via kubectl
kubectl get nodes --label-columns failure-domain.beta.kubernetes.io/zone

# get a minimalistic visual representation of your cluster
# note the ui is currently only in beta state
kubeone ui -t /training/tf_infra
```

## Verify via your application

```bash
# switch back to the namespace `default`
kubens default

# apply the manifests for the application
kubectl apply -f /training/06_apps/

# verify pods running in different zones
# => kubernetes tries, by default, to schedule pods of a deployment across the available worker nodes
kubectl get pods -o wide

# access the app via browser
kubectl port-forward service/my-service 80:8080

# clean up your application
kubectl delete -f /training/06_apps/
```
