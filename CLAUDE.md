# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Hands-on training labs for **KubeOne** (Kubermatic's Kubernetes lifecycle tool) on **GCE**. Each numbered directory is one lab; trainees run them in order against a real gcp project. There is no application source code here — labs are driven by `README.md` files plus a few YAML/Terraform manifests.

Two audiences share the repo, and edits usually target one of them: the **lab READMEs** that trainees follow, and the **`container-image/` build** that produces the environment they follow them in.

## Training Environment

The trainee environment is a container built from this repo (`container-image/dockerfile`, tag `kubeone:0.0.0`) running **code-server** as its entrypoint. Trainees work in a browser IDE, not in a devcontainer — `.devcontainer/devcontainer.json` still exists but is the legacy Codespaces path and its settings have drifted from `container-image/vscode_settings.json`.

The repo root is bind-mounted to `/training/`, so **every command in the lab READMEs assumes that path**.

Host-side lifecycle (from the repo root):

```bash
make lint     # hadolint on container-image/dockerfile
make build    # docker build --platform linux/amd64 -t kubeone:0.0.0
make run      # depends on build; docker rm --force + docker run
make clear    # docker rmi
```

Published ports, each with a distinct purpose:

| Port | Used by |
| --- | --- |
| 8080 | code-server IDE (`http://localhost:8080`) |
| 8081 | `kubeone ui --port 8081` |
| 8082 | `kubectl port-forward` for the demo app (labs 06, 08) |

Container preinstalls: `kubectl`, `terraform`, `helm`, `helmfile`, `velero`, `kubectx`/`kubens`, `krew`, `gcloud`. **`kubeone` is not preinstalled** — trainees install it themselves in lab 01.

In-container verification:

```bash
make verify
```

It asserts `/root/.trainingrc` exists and is sourced from `/root/.zshrc` (the shell is zsh + oh-my-zsh + powerlevel10k), that the CLI tools respond, that `GCP_PROJECT`, `TRAINEE_NAME`, `DOMAIN`, `DNS_ZONE_NAME`, `TRAINEE_EMAIL`, `S3_BUCKET`, `K8S_VERSION` and `TF_VERSION` are set, and that `/training/.secrets/` holds `gcp`, `gcp.pub` and `gcp-service-account.json`.

## Container Image

- **`container-image/dockerfile`** — `ubuntu:26.04` base, code-server, all CLI tooling. Versions are pinned via `ARG` and echoed into `/root/.trainingrc` so labs can reference them.
- **`container-image/vscode_settings.json`** — copied to `/root/.vscode/User/settings.json`. `editor.formatOnSave` is global, so any language trainees edit needs a `[language]` → `editor.defaultFormatter` entry, otherwise code-server prompts on save.
- Extensions are installed with `code-server --install-extension`, which resolves against **Open VSX**, not the MS marketplace. Marketplace-only extensions cannot be added without a manual `.vsix`.
- **The image is amd64-only.** `--platform linux/amd64` is pinned in both `build` and `run`, so it runs under Rosetta/QEMU on arm64 hosts. A native arm64 build fails: five hardcoded `amd64` download URLs, plus GNU tar 1.35 hitting an unimplemented `openat2` under Rosetta, which breaks the helm and velero extraction steps. A `TARGETARCH` migration would need all five URLs parameterised.

## Lab Sequence

1. `00_prerequisites` — trainer-supplied `environment.sh` and `gcp-service-account.json` are dropped into `/training/.secrets/`; `environment.sh` writes the env vars into `/root/.trainingrc`. Then generate the SSH keypair and activate the `gcloud` service account.
2. `01_install-k1` — install pinned KubeOne `1.14.2` via `curl -sfL https://get.kubeone.io | sh` (later upgraded to `1.14.3` in lab 15).
3. `02_terraform` — generate `*.tf` into `tf_infra/` via `kubeone init --provider gce`, then `terraform init|plan|apply`.
4. `03_low-availability-cluster` — `kubeone apply -t /training/tf_infra` against the root `kubeone.yaml`.
5. `04_additional-installed-components` — explore embedded addons (`kubeone addons list`).
6. `05_machinedeployments` — generate `md-initial.yaml` via `kubeone config machinedeployments`, edit, `kubectl apply`.
7. `06_apps` — install OCI Helm chart `quay.io/kubermatic-labs/helm-charts/training-application:1.0.1` with `training-application-values.yaml`.
8. `07_high-availability-controlplane` — scale `control_plane_vm_count` / `control_plane_target_pool_members_count` in `tf_infra/terraform.tfvars`.
9. `08_high-availability-workers` — fan `md-initial.yaml` out into per-zone `md-europe-west3-{a,b,c}.yaml`.
10. `09_helm-releases` — add `helmReleases:` for `ingress-nginx` + `cert-manager` to `kubeone.yaml`, apply `cluster-issuer.yaml`, create the DNS entry for the domain.
11. `11_autoscale-workers` — enable the embedded `cluster-autoscaler` addon; min/max managed via `cluster.k8s.io/cluster-api-autoscaler-node-group-{min,max}-size` annotations on MachineDeployments.
12. `13_backup-cluster` — back up the cluster with **restic**, using the `backups-restic` addon embedded in the kubeone binary. Lab downloads the kubeone source zip, copies the addon into `/training/addons/`, and points kubeone at that directory.
13. `14_upgrade-cluster` — bump `versions.kubernetes` in `kubeone.yaml`, `kubeone apply` for the control plane, edit `kubelet:` in all three MD manifests for workers.
14. `15_upgrade-k1` — install a newer kubeone binary, re-run `kubeone apply`.
15. `99_teardown` — `kubeone reset -t /training/tf_infra` then `terraform destroy`, plus DNS record and bucket cleanup.

## Key Files

- **`kubeone.yaml`** — root KubeOne manifest (`kubeone.k8c.io/v1beta2`, `KubeOneCluster`). Kubernetes `1.36.3`, `cloudProvider.gce`, `external: true` CCM. It deliberately holds **only** the base cluster spec — the `helmReleases:` block (lab 09) and the `addons:` block (labs 11, 13) are added by trainees. Keep the version at `1.36.3`: lab 14 upgrades to `1.36.4`, and `container-image/dockerfile` pins the matching kubectl. Most `kubeone` commands either run from `/training/` (auto-detect) or take `-m /training/kubeone.yaml`.
- **`tf_infra/`** — Terraform root for gcp infra (control plane VMs, LB, target pool, firewall rules, SSH keys). The **entire directory is gitignored**; only `terraform.tfvars` is force-tracked, carrying placeholder `<FILL-IN-...>` values. The `*.tf` files and `tf_infra/README.md` are generated by `kubeone init --provider gce` in lab 02, which is why `tf_infra/README.md` cannot be linked from GitHub. Pass the directory to KubeOne as `kubeone <cmd> -t /training/tf_infra` (KubeOne calls `terraform output -json` itself).
- **`training-application-values.yaml`** — Helm values for the demo app. Several labs mutate `deployment.replicas`, `ingress.enabled`, `ingress.domain`, `persistMetaInfo`.
- **`09_helm-releases/cluster-issuer.yaml`** — Let's Encrypt ClusterIssuer; trainees `sed` in their email.
- **`13_backup-cluster/backups-restic.yaml`** — restic backup addon manifest.
- **`.secrets/`** (gitignored) — `gcp` / `gcp.pub` SSH keypair, `gcp-service-account.json`, and the trainer-supplied `environment.sh`.
- **`.99_todos/`** — internal trainer notes, not labs. `.99_todos/12_backup-user-data/` holds the retired velero lab and its `storageclass.yaml`.

## Common Commands

Run inside the container, from `/training/`:

```bash
# provision/update gcp infra
terraform -chdir=/training/tf_infra apply

# create or reconcile the cluster
kubeone apply -t /training/tf_infra --verbose [-y]

# inspect cluster
kubeone status -t /training/tf_infra
kubeone ui -t /training/tf_infra --port 8081

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

- Every `kubeone` invocation in the labs uses `-t /training/tf_infra` to pull gcp host info from Terraform outputs. There is no separate `output.json` — KubeOne re-runs `terraform output` itself.
- KubeOne authenticates over SSH via **ssh-agent**, because the Terraform output carries `ssh_agent_socket = "env:SSH_AUTH_SOCK"` alongside `ssh_private_key_file`, and the agent is tried first. Without a running agent, `kubeone apply` fails with `could not open socket "env:SSH_AUTH_SOCK"` even though `ssh -i /training/.secrets/gcp` works. Lab 00 sets the agent up and appends it to `/root/.trainingrc`.
- Trainee state lives in `/root/.trainingrc` (sourced from `/root/.zshrc`). New env vars are appended with `echo ... >> /root/.trainingrc`. Version bumps use `sed -i` against this file (e.g. `KUBEONE_VERSION`, `K8S_VERSION`).
- MachineDeployment manifests are generated as `/training/md-*.yaml` and edited via `sed` — the labs depend on specific stable strings (`pool1`, `europe-west3-a`, `machineType: n1-standard-4` → `n1-standard-1`, `diskSize: 50` → `20`, `kubelet: 1.36.3`). Preserve those exact strings when editing example commands.
- gcp LB target pool gotcha (lab 07): `control_plane_target_pool_members_count` must initially be `1` and only be raised to `3` *after* the additional control plane nodes exist, otherwise terraform recreates the pool incorrectly.
- GCE-CCM ingress firewall bug (lab 08): new MD worker nodes do not receive ingress traffic by default; the training environment ships an `allow-ingress-gcp-ccm-bug-md` firewall rule as a workaround.
- Numbering skips `10` and `12`. Lab `11_autoscale-workers` follows `09_helm-releases`, and `13_backup-cluster` follows `11`. The velero lab that used to be `12` is retired under `.99_todos/`.
- **Three tracked files are mutated by the labs themselves and get committed by accident** — `kubeone.yaml` (`versions.kubernetes`, `helmReleases:`, `addons:`), `training-application-values.yaml` (`replicas`, `ingress.enabled`, `ingress.domain`) and `09_helm-releases/cluster-issuer.yaml` (`email`). Commit `6a93cf6` shipped all three carrying a live run's state, including a real trainer email and domain. Check them with `git diff` before pushing after a training.
- Cross-platform trainee risks live in the bind mount, not the architecture: lab 00 runs `chmod 0700` on `environment.sh` and `chmod 400` on the SSH key. Both work on macOS, but on Windows they only stick if the repo lives inside the WSL2 filesystem rather than under `/mnt/c/...`. A CRLF `environment.sh` fails with `bash: $'\r': command not found`.

## Known Inconsistencies

Facts a future instance would otherwise rediscover; none of these have been decided on yet.

- **`TRAINEE_EMAIL` and `S3_BUCKET` are only ever set by the trainer's `environment.sh`** (labs 09 and 13 consume them). `make verify` now asserts both, so an `environment.sh` that omits them fails lab 00 instead of lab 09. `00_prerequisites/README.md` still carries a `# TODO S3 stuff` marker.
- **`velero` is still installed and checked by `make verify`** although the velero lab is retired.
- **`06_apps` and `09_helm-releases` pass the chart version as an OCI tag** (`oci://…/training-application:1.0.1`); Helm documents `--version 1.0.1` against an untagged ref. Unverified — the labs appear to run as written.
- **`.devcontainer/devcontainer.json`** uses the deprecated `terminal.integrated.shell.linux`, has a `.gititnore` typo in `files.exclude`, and its settings have diverged from `container-image/vscode_settings.json`. Both files are needed — code-server reads `/root/.vscode/User/settings.json`, the VS Code Server in a devcontainer reads `~/.vscode-server/data/...` — but they must be kept in sync.
