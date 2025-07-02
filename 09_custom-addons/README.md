
## Add ingress-nginx and cert-manager to your Cluster

<https://docs.kubermatic.com/kubeone/main/guides/addons/>

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

# get the name of the installed ingress class
kubectl get ingressclasses

# verify all pods in the namespace `cert-manager` are running
kubectl -n cert-manager get pods
```

## Create proper DNS entry for the ingress controller

For the certmanager DNS challenge we have to set up proper DNS entries.

```bash
# persist the IP address of the nginx inress controller loadbalancer
echo "export INGRESS_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify
echo $INGRESS_IP

# create wildcard DNS entry
gcloud dns record-sets transaction start --zone=$DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone=$DNS_ZONE_NAME --ttl 60 --name="*.$DOMAIN." --type A $INGRESS_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME

# verify via gcloud
gcloud dns record-sets list --zone=$DNS_ZONE_NAME

# verify via nslookup
nslookup test.$DOMAIN
```

## Create a cluster issuer for cert-manager

```bash
# change the email address in the manifest `cluster-issuer.yaml` to your email address
sed -i "s/your-email@example.com/<FILL-IN-YOUR-EMAIL-ADRRESS>/g" /training/09_custom-addons/cluster-issuer.yaml

# verify
cat /training/09_custom-addons/cluster-issuer.yaml

# apply the cluster-issuer to your cluster
kubectl apply -f /training/09_custom-addons/cluster-issuer.yaml

# verify cluster issuer
kubectl describe clusterissuer letsencrypt-issuer
```

## Add the training app via custom addon

Add the helm release to the kubone manifest file `/training/kubeone.yaml`.

```yaml
  - releaseName: my-app
    chart: my-app
    chartURL: my-app/
    namespace: my-app
    version: 1.0.0
    values:
      - inline:
          color: #6a8f54
          message: "Hello from the app inside the k1 k8s cluster via custom addon"
          domain: "<FILL-IN-YOUR-DOMAIN>"     # <= you can get this value via `echo $DOMAIN`
```

```bash
# add the releases to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose

# verify all pods in the namespace `ingress-nginx` are running
kubectl -n ingress-nginx get pods

# get the name of the installed ingress class
kubectl get ingressclasses

# verify all pods in the namespace `cert-manager` are running
kubectl -n cert-manager get pods
```
