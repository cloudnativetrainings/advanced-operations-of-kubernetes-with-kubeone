# Custom Addons

In this lab you will deploy additional functionalities (eg the ingress stack) into your kubernetes cluster via kubeone. Besides Helm charts provided via chart repositories you can define and add your own local helm charts to your cluster.

> **NOTE:**
> The [helm integration](https://docs.kubermatic.com/kubeone/main/guides/helm-integration/) is available in kubeone since version 1.10.0 and this is the recommended way of adding additional functionalities to your kubernetes cluster. In older version this was done via [custom addons](https://docs.kubermatic.com/kubeone/main/guides/addons>)

## Charts from chart repositories

Let's add the ingress-nginx and cert-manager stack to your cluster. This will allow us to expose our application via a public URL with proper TLS certificates in place.

Add the following to your kubone manifest file `/training/kubeone.yaml`:

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

Apply the changes into your cluster:

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

### Create proper DNS entry for the ingress controller

For the certmanager DNS challenge we have to set up proper DNS entries.

```bash
# persist the IP address of the nginx inress controller loadbalancer
echo "export INGRESS_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify
echo $INGRESS_IP

# create wildcard DNS entry
gcloud dns record-sets transaction start --zone $DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone $DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $INGRESS_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME

# verify via gcloud
gcloud dns record-sets list --zone $DNS_ZONE_NAME

# verify via nslookup
nslookup $DOMAIN
```

### Create a cluster issuer for cert-manager

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

## Add your own charts

Add the helm release to the kubone manifest file `/training/kubeone.yaml`.

```yaml
  - releaseName: my-app
    chart: my-app
    chartURL: my-app/
    namespace: my-app
    version: 1.0.0
    values:
      - inline:
          color: lightblue
          message: "Hello from the app inside the k1 k8s cluster via custom addon"
          domain: "<FILL-IN-YOUR-DOMAIN>"     # <= you can get this value via `echo $DOMAIN`
```

```bash
# add the releases to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose

# switch to namespace `my-app`
kubens my-app

# verify your app got deployed properly
kubectl get service,endpoints,deployment,replicaset,pod

# verify your app via port-forwarding
kubectl port-forward service/my-app 80:80

# verify the ingress rule
kubectl describe ingress my-app

# verify certmanager finished the cert tango
kubectl get certs

# visit your app in your prefered browser
# => note that the traffic is encrypted
echo https://$DOMAIN

# verify via curl
curl -vvi https://$DOMAIN
```
