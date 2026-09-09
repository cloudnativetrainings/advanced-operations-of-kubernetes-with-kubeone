# Prerequisites

In this lab you will ensure everything is in place to create a Kubernetes cluster via kubeone.

## Copy your Training Files

```bash
# create a directory for holding sensitive information
mkdir /training/.secrets
```

Drag and drop the files (provided by the trainer) into the directory `/training/.secrets/`:

- environment.sh
- gcp-service-account.json

## Set important environment variables

> **IMPORTANT:**
> These variables will get referenced during the following labs. Make sure to set them before continuing.

```bash
# make the shell script executable
chmod 0700 /training/.secrets/environment.sh

# persist the environment variables into the file /root/.trainingrc
/training/.secrets/environment.sh

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify
echo $GCP_PROJECT
echo $TRAINEE_NAME
echo $DOMAIN
echo $DNS_ZONE_NAME

# TODO S3 stuff
```

## Ensure SSH requirements

Kubeone needs an SSH key pair for communicating with the control plane and worker nodes.

```bash
# create a ssh-key-pair for gce
ssh-keygen -q -N "" -t rsa -f /training/.secrets/gcp -C root

# ensure proper private key file permissions
chmod 400 /training/.secrets/gcp

# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /training/.secrets/gcp" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify agent is running and holds proper key
ssh-add -l | grep "$(ssh-keygen -lf /training/.secrets/gcp)"

# TODO ssh-agent stuff should not be necessary anymore and uglifies the prompt
```

## Configure gcp

<!-- TODO note only needed for gcloud cli, not for terraform, not for k1 -->

```bash
# activate gcp account
gcloud auth activate-service-account --key-file=/training/.secrets/gcp-service-account.json

# set the gcp project
gcloud config set project $GCP_PROJECT --quiet

# set the compute region and zone
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a

# verify your settings
gcloud config list
```

## Verify your environment

```bash
# ensure all environment variables get set in your current bash
source /root/.trainingrc

# verify
make verify
```
