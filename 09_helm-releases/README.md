# Adding Helm Releases

In this lab you will deploy additional functionalities (e.g. the ingress stack) into your Kubernetes cluster via kubeone. Besides Helm charts provided via chart repositories you can define and add your own local helm charts to your cluster.

> **NOTE:**
> The [helm integration](https://docs.kubermatic.com/kubeone/main/guides/helm-integration/) is available in kubeone since version 1.10.0 and this is the recommended way of adding additional functionalities to your Kubernetes cluster. In older versions this was done via [custom addons](https://docs.kubermatic.com/kubeone/main/guides/addons/).

## Charts from chart repositories

We'll use the Kubernetes Gateway API via Envoy Gateway for exposing workloads, and keep `cert-manager` for certificate issuance.

In this lab we'll:

- install `cert-manager` for TLS management
- install Envoy Gateway
- configure a Gateway Class and a Gateway

Then add `cert-manager` as a Helm release in your `kubeone.yaml` (we keep this the same as before for TLS):

```yaml
helmReleases:
  - releaseName: cert-manager
    chart: cert-manager
    repoURL: https://charts.jetstack.io
    namespace: cert-manager
    version: v1.17.2
    values:
      - inline:
          crds:
            enabled: true
          config:
            apiVersion: "controller.config.cert-manager.io/v1alpha1"
            kind: "ControllerConfiguration"
            enableGatewayAPI: true
  - releaseName: envoy-gateway
    chartURL: oci://docker.io/envoyproxy/gateway-helm
    namespace: envoy-gateway-system
    version: v1.9.2
```

Apply the changes into your cluster:

```bash
# add the releases to the kubernetes cluster
kubeone apply -t /training/tf_infra --verbose -y
```

```bash
# verify via helm
helm ls --all-namespaces
```

```bash
# verify envoy gateway pods
kubectl -n envoy-gateway-system get pods
```

Review the definition for the gateway class and gateway in `09_helm-releases/gateway.yaml`
and add your domain under
```
    hostname: <YOUR_DOMAIN>
```

```bash
# apply gateway class and gateway definition
kubectl apply -f 09_helm-releases/gateway.yaml
```

```bash
# inspect available GatewayClasses
kubectl get gatewayclasses
```

```bash
# verify all pods in the namespace `cert-manager` are running
kubectl -n cert-manager get pods
```

### Create proper DNS entry for the gateway controller

So that cert-manager's HTTP challenge (and your users) can reach the domain, we have to set up proper DNS entries.

```bash
# persist the IP address of your Gateway/Controller loadbalancer (adapt namespace & service name)
echo "export GATEWAY_IP=$(kubectl get gateway/eg -o jsonpath='{.status.addresses[0].value}')" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify
echo $GATEWAY_IP
```

```bash
# create the DNS entry for your domain
gcloud dns record-sets transaction start --zone $DNS_ZONE_NAME
gcloud dns record-sets transaction add --zone $DNS_ZONE_NAME --ttl 60 --name="$DOMAIN." --type A $GATEWAY_IP
gcloud dns record-sets transaction execute --zone $DNS_ZONE_NAME

# verify via gcloud
gcloud dns record-sets list --zone $DNS_ZONE_NAME

# verify via dig
dig +short A $DOMAIN
```

### Create a cluster issuer for cert-manager

```bash
# change the email address in the manifest `/training/09_helm-releases/cluster-issuer.yaml` to your email address
sed -i "s/your-email@example.com/$TRAINEE_EMAIL/g" /training/09_helm-releases/cluster-issuer.yaml
```

```bash
# verify
code /training/09_helm-releases/cluster-issuer.yaml
```

```bash
# Create a secret for Google Cloud DNS service account and set your GCP project
# Adjust the path to your service account JSON if different. This stores the key in `cert-manager`'s namespace.
kubectl create secret generic clouddns-sa --from-file=key.json=/training/.secrets/gcp-service-account.json -n cert-manager

# Replace the placeholder <GCP_PROJECT> in `/training/09_helm-releases/cluster-issuer.yaml` with your project ID
# For an interactive session use an environment variable:
export GCP_PROJECT="your-gcp-project-id"

# Or persist it for the trainee environment so subsequent shells see it:
echo "export GCP_PROJECT=your-gcp-project-id" >> /root/.trainingrc
source /root/.trainingrc

# Now apply the ClusterIssuer (it references the `clouddns-sa` secret and the project)
kubectl apply -f /training/09_helm-releases/cluster-issuer.yaml
```

```bash
# verify cluster issuer
kubectl describe clusterissuer letsencrypt-issuer
```

## Make use of added functionalities in your application

First you have to adapt your application values to expose it via the Gateway API (HTTPRoute). Edit `/training/training-application-values.yaml`.

```yaml
deployment:
  replicas: 1                     # <= set this value to 3

gateway:
  enabled: true                   # <= enable HTTPRoute generation
  hostnames: ["<your domain>"]    # <= update to your domain
  name: eg                        # <= the Gateway resource name to attach to
  namespace: training-application # <= the Gateway resource namespace
```

```bash
# re-release your application
helm upgrade --install --atomic --debug \
  --namespace training-application --create-namespace training-application \
  oci://quay.io/kubermatic-labs/helm-charts/training-application:1.0.2 \
  -f /training/training-application-values.yaml
```

```bash
# switch to namespace `training-application`
kubens training-application
```

```bash
# verify via helm
helm ls
```

```bash
# verify your app got deployed properly
kubectl get service,endpoints,deployment,replicaset,pod
```

```bash
# verify the http route
kubectl describe httproute -n training-application my-app-httproute
```

```bash
# verify certmanager finished the cert tango
kubectl get certs
```

```bash
# verify your app in your preferred browser
# => note that the traffic is encrypted
echo https://$DOMAIN
```

```bash
# verify via curl
curl -vvi https://$DOMAIN
```

## Engage "poor-man's-application-monitoring"

```bash
# Open a new terminal
# => with this we monitor the pods getting into running state
while true; do curl -I https://$DOMAIN ; sleep 10s; done;
```
