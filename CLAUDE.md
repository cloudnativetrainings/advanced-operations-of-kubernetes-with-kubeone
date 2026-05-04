# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Hands-on training labs for **KubeOne** (Kubermatic's Kubernetes lifecycle tool) on **GCE**. Each numbered directory is one lab; trainees run them in order against a real GCE project. There is no application source code here — labs are driven by `README.md` files plus a few YAML/Terraform manifests.

## Training Environment

Delivered via Dev Container (`.devcontainer/devcontainer.json`) using image `quay.io/kubermatic-labs/training-ghcs-advanced-operations-of-kubernetes-with-kubeone-trainee-environment:1.0.0`. Repo root is bind-mounted to `/training/` inside the container, so every command in the lab READMEs assumes that path.

Container preinstalls: `kubectl`, `kubeone`, `terraform`, `helm`, `velero`, `kubectx`/`kubens`, `gcloud`.

`make verify` is the one repo-level "test": it asserts `.trainingrc` exists and is sourced from `.bashrc`, required env vars are set (`GCE_PROJECT`, `TRAINEE_NAME`, `DOMAIN`, `DNS_ZONE_NAME`, `K8S_VERSION`, `TF_VERSION`), and SSH/GCE credentials are placed under `/training/.secrets/`.

## Lab Sequence

1. `00_prerequisites` — set env vars in `/root/.trainingrc`, generate SSH keypair, activate `gcloud` service account.
2. `01_install-k1` — install pinned KubeOne `1.12.2` (later upgraded to `1.12.3` in lab 15).
3. `02_terraform` — copy `*.tf` from the kubeone release into `tf_infra/`, then `terraform init|plan|apply`.
4. `03_low-availability-cluster` — `kubeone apply -t /training/tf_infra` against the root `kubeone.yaml`.
5. `04_additional-installed-components` — explore embedded addons (`kubeone addons list`).
6. `05_machinedeployments` — generate `md-initial.yaml` via `kubeone config machinedeployments`, edit, `kubectl apply`.
7. `06_apps` — install OCI Helm chart `quay.io/kubermatic-labs/helm-charts/training-application:1.0.1` with `training-application-values.yaml`.
8. `07_high-availability-controlplane` — scale `control_plane_vm_count` / `control_plane_target_pool_members_count` in `tf_infra/terraform.tfvars`.
9. `08_high-availability-workers` — fan `md-initial.yaml` out into per-zone `md-europe-west3-{a,b,c}.yaml`.
10. `09_helm-releases` — add `helmReleases:` block to `kubeone.yaml` for `ingress-nginx` + `cert-manager`, apply `cluster-issuer.yaml`, set up wildcard DNS.
11. `11_autoscale-workers` — enable embedded `cluster-autoscaler` addon; min/max managed via `cluster.k8s.io/cluster-api-autoscaler-node-group-{min,max}-size` annotations on MachineDeployments.
12. `12_backup-user-data` — install `velero` with GCS bucket, backup/restore `training-application` namespace + PV.
13. `14_upgrade-cluster` — bump `versions.kubernetes` in `kubeone.yaml`, `kubeone apply` for control plane, edit `kubelet:` in MD manifests for workers.
14. `15_upgrade-k1` — install newer kubeone binary, re-run `kubeone apply`.
15. `99_teardown` — `kubeone reset -t /training/tf_infra` then `terraform destroy`, plus DNS record and GCS bucket cleanup.

## Key Files

- **`kubeone.yaml`** — root KubeOne manifest (`kubeone.k8c.io/v1beta2`, `KubeOneCluster`). Kubernetes `1.34.4`, `cloudProvider.gce`, `external: true` CCM. Most `kubeone` commands either run from `/training/` (auto-detect) or take `-m /training/kubeone.yaml`.
- **`tf_infra/`** — Terraform root for GCE infra (control plane VMs, LB, target pool, firewall rules, SSH keys). `terraform.tfvars` is checked in with placeholder `<FILL-IN-...>` values; `*.tf` files are gitignored because they get copied from `kubeone_${K1_VERSION}_linux_amd64/examples/terraform/gce/` during lab 02. Pass it to KubeOne as `kubeone <cmd> -t /training/tf_infra` (KubeOne calls `terraform output -json` automatically).
- **`training-application-values.yaml`** — Helm values for the demo app. Several labs mutate `deployment.replicas`, `ingress.enabled`, `ingress.domain`, `persistMetaInfo`.
- **`09_helm-releases/cluster-issuer.yaml`** — Let's Encrypt ClusterIssuer; trainees `sed` in their email.
- **`12_backup-user-data/storageclass.yaml`** — StorageClass needed before enabling `persistMetaInfo`.
- **`.secrets/`** (gitignored) — holds `gce` / `gce.pub` SSH keys and `gcloud-service-account.json`.

## Common Commands

```bash
# verify trainee env (needs env vars + .secrets in place)
make verify

# provision/update GCE infra
terraform -chdir=/training/tf_infra apply

# create or reconcile the cluster
kubeone apply -t /training/tf_infra --verbose [-y]

# inspect cluster
kubeone status -t /training/tf_infra
kubeone ui -t /training/tf_infra

# get / set kubeconfig
kubeone kubeconfig -t /training/tf_infra > /root/.kube/config

# generate initial MachineDeployment manifest
kubeone config machinedeployments -t /training/tf_infra > /training/md-initial.yaml

# list embedded addons + their status
kubeone addons list -t /training/tf_infra

# tear everything down
kubeone reset -t /training/tf_infra
terraform -chdir=/training/tf_infra destroy
```

## Conventions / Gotchas

- Every `kubeone` invocation in the labs uses `-t /training/tf_infra` to pull GCE host info from Terraform outputs. There is no separate `output.json` — KubeOne re-runs `terraform output` itself.
- Trainee state lives in `/root/.trainingrc` (sourced from `/root/.bashrc`). New env vars are appended with `echo ... >> /root/.trainingrc`. Version bumps use `sed -i` against this file (e.g. `K1_VERSION`, `K8S_VERSION`).
- The MachineDeployment manifests are generated locally as `/training/md-*.yaml` and edited via `sed` — the labs rely on specific stable strings (e.g. `pool1`, `europe-west3-a`, `machineType: n1-standard-2`, `diskSize: 50`, `kubelet: 1.34.4`). Preserve those exact strings when editing example commands.
- GCE LB target pool gotcha (lab 07): `control_plane_target_pool_members_count` must initially be `1` and only be raised to `3` *after* the additional control plane nodes exist, otherwise terraform recreates the pool incorrectly.
- GCE-CCM ingress firewall bug (lab 08): new MD worker nodes do not receive ingress traffic by default; the training environment ships an `allow-ingress-gce-ccm-bug-md` firewall rule as a workaround.
- Numbering skips `10` and `13` intentionally — labs `11_autoscale-workers` and `12_backup-user-data` follow `09_helm-releases` directly. The `.99_todos/13_backup-system-data` directory is internal trainer notes, not a lab.
