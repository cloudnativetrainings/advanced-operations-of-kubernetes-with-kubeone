# Advanced Operations of Kubernetes with KubeOne

In this training you will learn how to use KubeOne to provision Kubernetes Clusters.

## Setup the training environment

### Clone the Git Repo

```bash
git clone https://github.com/cloudnativetrainings/advanced-operations-of-kubernetes-with-kubeone.git
```

### Run the k1-workshop Container

```bash
docker run -it -d --platform linux/amd64 \
  --name k1-workshop \
  --restart=always \
  --cpus=2 \
  --memory=4g \
  -p 8080:8080 \
  -p 8081:8081 \
  -p 8082:8082 \
  --hostname k1-workshop \
  -v $(PWD)/advanced-operations-of-kubernetes-with-kubeone:/training \
  TODO public image
```

### Access your k1-workshop IDE with your browser

The url therefore is http://localhost:8080
