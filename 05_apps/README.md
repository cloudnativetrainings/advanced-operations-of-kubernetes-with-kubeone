# Apps

In this lab you will test if the cluster works as expected.

## Deploy the app

```bash
# deploy the application
kubectl apply -f /training/05_apps/

# verify everything is running
kubectl get service,endpoints,deployment,pods,configmap

# check the resource needs of the pod (which indicates also metrics-server is running)
kubectl top pods

# access the app via browser
kubectl port-forward service/my-service 80:8080
```

## Scale the app

> **NOTE:**
> You have to run these commands in a different bash, due to port-forwarding is blocking the first bash.

```bash
# scale the app
kubectl scale deployment my-deployment --replicas 3

# verify everything is running
kubectl get service,endpoints,deployment,pods,configmap
```

## Clean-up

```bash
# delete the application
kubectl delete -f /training/05_apps/
```
