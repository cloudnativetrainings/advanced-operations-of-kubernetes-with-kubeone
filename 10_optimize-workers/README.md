# Optimize Worker Nodes

In this lab you will make changes to the worker nodes to keep cloud costs, in our case GCE, low.

## Preparations

```bash
# inspect the resource usage of the nodes
kubectl top nodes

# change the diskType from `n1-standard-2` to `n1-standard-1` in the machinedeployments manifests
sed -i "s/machineType: n1-standard-2$/machineType: n1-standard-1/g" /training/md-europe-west3-a.yaml
sed -i "s/machineType: n1-standard-2$/machineType: n1-standard-1/g" /training/md-europe-west3-b.yaml
sed -i "s/machineType: n1-standard-2$/machineType: n1-standard-1/g" /training/md-europe-west3-c.yaml

# change the diskSize from 50 GB to 20 GB in the machinedeployments manifests
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-a.yaml
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-b.yaml
sed -i "s/diskSize: 50$/diskSize: 20/g" /training/md-europe-west3-c.yaml

# change the machineType in the machinedeployments manifests
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-a.yaml
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-b.yaml
sed -i "s/diskType: pd-ssd$/diskType: pd-standard/g" /training/md-europe-west3-c.yaml
```

## Put monitoring in place

For being able to monitor zero downtime upgrade we put a proper monitoring in place.

```bash
# Open a new bash in Google Cloud Shell
# => with this we monitor the changes on the vms
[BASH-2] watch -n 1 kubectl -n kube-system get machinedeployment,machineset,machines,nodes

# Open a new bash in Google Cloud Shell
# => with this we monitor the availability of the applied application
[BASH-3] while true; do curl -I https://$DOMAIN; sleep 10s; done;
```

<!-- TODO fail due to LB issues -->

## Trigger the rolling update

```bash
# apply the new md manifests and watch the changes in the other bashes
kubectl apply -f /training/md-europe-west3-a.yaml
kubectl apply -f /training/md-europe-west3-b.yaml
kubectl apply -f /training/md-europe-west3-c.yaml
```
