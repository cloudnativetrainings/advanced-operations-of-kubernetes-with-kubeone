# Apps

In this lab you will test if the cluster works as expected.

## Deploy the app

```bash
# deploy the application
# TODO use helm chart from repo
helm upgrade --install --atomic --debug \
  --namespace training-application --create-namespace training-application \
  oci://quay.io/kubermatic-labs/helm-charts/training-application:1.0.1 \
  -f /training/training-application-values.yaml

# verify everything is running
kubectl -n training-application get service,endpoints,deployment,pods,configmap

# access the app via browser
kubectl -n training-application port-forward service/my-app 80:80
```

>**NOTE:**
>Keep the application running, we will use it later on.
