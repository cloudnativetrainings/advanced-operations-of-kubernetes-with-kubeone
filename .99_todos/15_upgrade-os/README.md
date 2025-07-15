
### OS Upgrades

At Ubuntu, it's recommended to set the flag `distUpgradeOnBoot: true` in the `MachineDeployment:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
#...
spec: 
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: ubuntu
          operatingSystemSpec:
            distUpgradeOnBoot: true
```

This ensures that during the bootstrapping of new nodes, all needed OS updated get installed.

For Flatcar Linux, KubeOne installs automatically the Flatcar OS update operator [kinvolk/flatcar-linux-update-operator](https://github.com/kinvolk/flatcar-linux-update-operator) what manage the upgrades if your spec is:

```yaml
apiVersion: cluster.k8s.io/v1alpha1
kind: MachineDeployment
#...
spec: 
  template:
    spec:
      providerSpec:
        value:
          operatingSystem: flatcar
          operatingSystemSpec:
            disableAutoUpdate: false
```

Jump > [**Home**](../README.md) | Previous > [**KubeOne AddOns**](../10_addons-sc-and-restic-etcd-backup/README.md) | Next > [**Cluster AutoScaling**](../12_cluster-autoscaling/README.md)
