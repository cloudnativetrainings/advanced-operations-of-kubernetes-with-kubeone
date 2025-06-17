# Advanced Operations of Kubernetes with KubeOne

## Setup training environment

```bash
# activate your gcloud service account
# copy your file `gcloud-service-account.json` into your github codespaces workspace
# gcloud auth activate-service-account --key-file=./gcloud-service-account.json
# gcloud config set project <PROJECT_ID>
# gcloud config set compute/region europe-west3
# gcloud config set compute/zone europe-west3-a

# create a ssh-key-pair for gcloud
ssh-keygen -q -N "" -t rsa -f ~/.ssh/google_compute_engine -C root

# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /root/.ssh/google_compute_engine" >> /root/.trainingrc
source /root/.trainingrc

# verify training environment
make verify
```

<!-- # edit kubeone.yaml

# /home/codespace/id_rsa  => /home/codespace/.ssh/id_rsa

# terraform.tfvars

# TODO clustername

# TODO project id

## Teardown training environment

```bash
make teardown
``` -->
