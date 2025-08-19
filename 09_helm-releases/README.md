# Adding Helm Releases

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
kubeone apply -t /training/tf_infra --verbose -y

# verify via helm
helm ls --all-namespaces

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
sed -i "s/your-email@example.com/hubert@kubermatic.com/g" /training/09_helm-releases/cluster-issuer.yaml
 
# verify
cat /training/09_helm-releases/cluster-issuer.yaml

# apply the cluster-issuer to your cluster
kubectl apply -f /training/09_helm-releases/cluster-issuer.yaml

# verify cluster issuer
kubectl describe clusterissuer letsencrypt-issuer
```

## Make use of added functionalities in your application

First you have to adapt your application to make use of ingress-nginx and certmanager. Adapt the file `/training/training-application-values.yaml`.

```yaml
deployment:
  replicas: 1              # <= set this value to 3

ingress:
  enabled: false           # <= set this value to true
  domain: example.com      # <= fill in your domain, you can get yours via `echo $DOMAIN`
```

```bash
# re-release your application
helm upgrade --install --atomic --debug \
  --namespace training-application --create-namespace training-application \
  oci://quay.io/kubermatic-labs/helm-charts/training-application:1.0.1 \
  -f /training/training-application-values.yaml

# switch to namespace `training-application`
kubens training-application

# verify via helm
helm ls

# verify your app got deployed properly
kubectl get service,endpoints,deployment,replicaset,pod

# verify the ingress rule
kubectl describe ingress my-app

# verify certmanager finished the cert tango
kubectl get certs

# verify your app in your prefered browser
# => note that the traffic is encrypted
echo https://$DOMAIN

# verify via curl
curl -vvi https://$DOMAIN
```

## Engage "poor-mans-application-monitoring""

```bash
# Open a new bash in Google Cloud Shell
# => with this we monitor the pods getting into running state
while true; do curl -I https://$DOMAIN; sleep 10s; done;
```
