# High Availability Worker Nodes

In this lab you will provision two additional nodes and ensure that they are running in different zones within the GCE region.

## Create the new MachineDeployment Manifests

```bash
# make copies of the old machinedeployment manifest `md-initial.yaml`
cp /training/md-initial.yaml /training/md-europe-west3-a.yaml
cp /training/md-initial.yaml /training/md-europe-west3-b.yaml
cp /training/md-initial.yaml /training/md-europe-west3-c.yaml

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

## Optimize Worker Nodes

```bash
# change the machine type from `n1-standard-2` to `n1-standard-1` in the machinedeployments manifests
sed -i "s/machineType: n1-standard-4$/machineType: n1-standard-1/g" /training/md-europe-west3-a.yaml
sed -i "s/machineType: n1-standard-4$/machineType: n1-standard-1/g" /training/md-europe-west3-b.yaml
sed -i "s/machineType: n1-standard-4$/machineType: n1-standard-1/g" /training/md-europe-west3-c.yaml

# change the disk size from 50 GB to 20 GB in the machinedeployments manifests
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-a.yaml
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-b.yaml
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-c.yaml

# change the disk type in the machinedeployments manifests
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-a.yaml
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-b.yaml
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-c.yaml

# ensure os update on boot
sed -i "s/distUpgradeOnBoot: false$/distUpgradeOnBoot: true/g" /training/md-europe-west3-a.yaml
sed -i "s/distUpgradeOnBoot: false$/distUpgradeOnBoot: true/g" /training/md-europe-west3-b.yaml
sed -i "s/distUpgradeOnBoot: false$/distUpgradeOnBoot: true/g" /training/md-europe-west3-c.yaml
```

## Apply the new MachineDeployment Manifests to your Cluster

```bash
# apply the new md manifests
kubectl apply -f /training/md-europe-west3-a.yaml
kubectl apply -f /training/md-europe-west3-b.yaml
kubectl apply -f /training/md-europe-west3-c.yaml

# delete the old md
kubectl delete -f /training/md-initial.yaml

# watch the resources getting changed by machinecontroller
watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machine,node

# verify via gcloud
gcloud compute instances list

# verify via kubectl
kubectl get nodes --label-columns failure-domain.beta.kubernetes.io/zone
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

>**NOTE:**
> Due to a bug in the GCE-CCM the newly created worker nodes will not get any ingress traffic. This is fixed the training environment, but not if you try it on your own.
> Take a look via `gcloud compute firewall-rules describe allow-ingress-gce-ccm-bug-md` for details.
