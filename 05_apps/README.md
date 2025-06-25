# Apps

In this lab you will test if the cluster works as expected.

## Deploy the app

```bash
# deploy the application
kubectl apply -f /training/05_apps/

# verify everything is running
kubectl get service,endpoints,deployment,pods,configmap

# access the app via browser
kubectl port-forward service/my-service 80:8080
```

## Clean-up

```bash
# delete the application
kubectl delete -f /training/05_apps/
```
