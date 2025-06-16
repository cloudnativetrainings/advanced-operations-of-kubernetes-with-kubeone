# Kubernetes Fundamentals for Operators

## Setup training environment

```bash
# activate your gcloud service account
# copy your file `gcloud-service-account.json` into your github codespaces workspace
gcloud auth activate-service-account --key-file=./gcloud-service-account.json
gcloud config set project <PROJECT_ID>
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a

# create a ssh-key-pair for gcloud
ssh-keygen -q -N "" -t rsa -f ~/.ssh/google_compute_engine -C root

# adapt bash environment
echo "export ETCD_VERSION=3.5.8" >> /root/.trainingrc
echo "export KUBERNETES_VERSION=1.28.9" >> /root/.trainingrc
echo "export RUNC_VERSION=1.1.12" >> /root/.trainingrc
echo "export CONTAINERD_VERSION=1.7.16" >> /root/.trainingrc
echo "export CRICTL_VERSION=1.30.0" >> /root/.trainingrc
echo "export CNI_PLUGINS_VERSION=1.4.1" >> /root/.trainingrc

echo "export PREFIX=<TRAINEE_NAME>" >> .trainingrc
source /root/.trainingrc

# verify training environment
make verify
```

## Teardown training environment

```bash
make teardown
```
