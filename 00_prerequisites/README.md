# Prerequisites

In this lab you will ensure everything is in place to create a kubernetes cluster via kubeone.

## Verify installed software

```bash
# verify kubectl is installed
kubectl version --client

# verify terraform is installed
terraform version
```

### Copy your Training Files

```bash
# create a directory for holding sensitive information
mkdir /training/.secrets
```

Drag and drop the files (provided by the trainer) into the directory `/training/.secrets/`:

- README.md
- environment.sh
- gcloud-service-account.json

## Set important environment variables

> **IMPORTANT:**
> These variables will get referenced during the following labs. Make sure to set them before continuing.
> You can find the needed information in the file `/training/.secrets/README.md`, but, for convenience there is also a shell script which will persist the environment variables in the file `/root/.trainingrc`.

```bash
# make the shell script executable
chmod 0700 /training/.secrets/environment.sh

# persist the environment variables into the file /root/.trainingrc
/training/.secrets/environment.sh

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify
echo $GCE_PROJECT
echo $TRAINEE_NAME
echo $DOMAIN
echo $DNS_ZONE_NAME
```

## Ensure SSH requirements

Kubeone needs an SSH key pair for communicating with the controlplane and worker nodes.

```bash
# create a ssh-key-pair for gce
ssh-keygen -q -N "" -t rsa -f /training/.secrets/gce -C root

# ensure proper private key file permissions
chmod 400 /training/.secrets/gce

# ensure .ssh key is known on environment restarts
echo 'eval `ssh-agent`' >> /root/.trainingrc
echo "ssh-add /training/.secrets/gce" >> /root/.trainingrc

# ensure changes are applied in your current bash
source /root/.trainingrc

# verify agent is running and holds proper key
ssh-add -l | grep "$(ssh-keygen -lf /training/.secrets/gce)"
```

## Configure gce

```bash
# activate gce account
gcloud auth activate-service-account --key-file=/training/.secrets/gcloud-service-account.json

# set the gce project
gcloud config set project $GCE_PROJECT --quiet

# set the compute region and zone
gcloud config set compute/region europe-west3
gcloud config set compute/zone europe-west3-a

# verify your settings
gcloud config list

# persist the google credentials into an environment variable (needed by terraform and k1)
echo "export GOOGLE_CREDENTIALS='$(cat /training/.secrets/gcloud-service-account.json)'" >> /root/.trainingrc
```

## Verify your environment

```bash
# ensure all environment variables get set in your current bash
source /root/.trainingrc

# verify
make verify
```
