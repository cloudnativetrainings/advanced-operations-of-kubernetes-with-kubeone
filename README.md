# Advanced Operations of Kubernetes with KubeOne

In this training you will learn how to bootstrap Kubernetes Clusters via KubeOne from within a Github Codespaces (AKA jump host).

## Verify installed software

```bash
# verify kubectl is installed
kubectl version --client

# verify terraform is installed
terraform version

# verify kubeone is installed
kubeone version
```

## Ensure SSH requirements

```bash
# create a ssh-key-pair for gcloud
ssh-keygen -q -N "" -t rsa -f ~/.ssh/google_compute_engine -C root

# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /root/.ssh/google_compute_engine" >> /root/.trainingrc
source /root/.trainingrc
```

## Verify your environment

```bash
make verify
```
