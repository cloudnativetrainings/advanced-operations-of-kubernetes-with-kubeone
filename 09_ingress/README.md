
## Add ingress-nginx and cert-manager to your Cluster

[kubeone docu](https://docs.kubermatic.com/kubeone/main/guides/helm-integration/)

```yaml
helmReleases:
  - releaseName: ingress-nginx
    chart: ingress-nginx
    repoURL: https://kubernetes.github.io/ingress-nginx
    namespace: ingress-nginx
    version: 4.12.2
    values:
      - inline:
          controller:
            replicaCount: 2
            autoscaling:
              enabled: true
              minReplicas: 2
              maxReplicas: 5
              targetCPUUtilizationPercentage: 80
              targetMemoryUtilizationPercentage: 80
  - releaseName: cert-manager
    chart: cert-manager
    repoURL: https://charts.jetstack.io
    namespace: cert-manager
    version: v1.17.2
    values:
      - inline:
          crds:
            enabled: true
```

```bash
# add the releases to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose

# verify all pods in the namespace `ingress-nginx` are running
kubectl -n ingress-nginx get pods

# verify all pods in the namespace `cert-manager` are running
kubectl -n cert-manager get pods
```

## DNS

```bash
gcloud dns record-sets transaction start --zone=event-01-hubert
gcloud dns record-sets transaction add --zone=event-01-hubert --ttl 60 --name="*.kubermatic.hubert.event-01.cloud-native.training." --type A 35.246.177.33
gcloud dns record-sets transaction execute --zone event-01-hubert

nslookup test.kubermatic.hubert.event-01.cloud-native.training
```
