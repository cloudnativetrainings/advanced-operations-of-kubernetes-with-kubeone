# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Hands-on training labs for **KubeOne** (Kubermatic's Kubernetes lifecycle tool) on **GCE**. Each numbered directory is one lab; trainees run them in order against a real gcp project. There is no application source code here — labs are driven by `README.md` files plus a few YAML/Terraform manifests.

Two audiences share the repo, and edits usually target one of them: the **lab READMEs** that trainees follow, and the **`container-image/` build** that produces the environment they follow them in.

## Training Environment

The trainee environment is a container built from this repo (`container-image/dockerfile`) running **code-server** as its entrypoint. It publishes as `quay.io/kubermatic-labs/training-ghcs-advanced-operations-of-kubernetes-with-kubeone-trainee-environment`; the tag lives in `container-image/makefile` (`IMAGE_TAG`) and must be bumped there and in `README.md` together. Trainees work in a browser IDE, not in a devcontainer — `.devcontainer/devcontainer.json` still exists but is the legacy Codespaces path and its settings have drifted from `container-image/vscode_settings.json`.

The repo root is bind-mounted to `/training/`, so **every command in the lab READMEs assumes that path**.

Host-side lifecycle lives in **`container-image/makefile`** and is run from that directory (the root `makefile` holds only the in-container `verify` target):

```bash
make lint     # hadolint on ./dockerfile
make build    # multi-arch buildx build (amd64 + arm64), loaded locally
make run      # depends on build; docker rm --force + docker run
make push     # depends on lint; same build, but --push to the registry
make clear    # docker rmi
```

`build` produces **both** platforms, so `make run` pays for an emulated amd64 build even when you only want to start the container locally. It also relies on Docker's **containerd image store** (`docker info` reports `Driver=overlayfs`): a multi-platform build with no `--load`/`--push` cannot be exported to the classic `overlay2` store and fails there.

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
- **The image is multi-arch (`linux/amd64` + `linux/arm64`).** Docker Desktop runs Linux containers in a VM whose arch follows the host CPU, so those two platforms cover macOS, Windows and Linux. `docker run` no longer pins `--platform`; each host pulls its native variant.
- **`ARG TARGETARCH` must stay without a default.** Buildx injects it per `--platform`, but a Dockerfile default *shadows* the injected value (measured on Docker 29.7.2) — `ARG TARGETARCH=amd64` silently yields an arm64 image full of amd64 binaries. It drives the five download URLs (kubectl, krew, helm, helmfile, velero); the arch spelling happens to match all five projects' naming. apt (gcloud, terraform, kubectx, code-server) resolves per-arch on its own.
- **`make push` requires `docker login quay.io` first.** It uses the default builder, which handles multi-platform here only because the containerd image store is on. BuildKit attaches provenance/SBOM attestations by default, so the pushed manifest list carries extra `unknown/unknown` entries alongside amd64 and arm64 — add `--provenance=false --sbom=false` if that ever needs to be a clean two-entry list.
- Extraction uses `bsdtar` (`libarchive-tools`) throughout, which is what keeps the emulated build working: GNU tar 1.35 hits an unimplemented `openat2` under QEMU/Rosetta and breaks the helm and velero steps.

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
- **`tf_infra/`** — Terraform root for gcp infra (control plane VMs, LB, target pool, firewall rules, SSH keys). The **entire directory is gitignored and nothing in it is tracked** — every file, `terraform.tfvars` included, is produced during the training. The `*.tf` files and `tf_infra/README.md` come from `kubeone init --provider gce` in lab 02, which is why `02_terraform/README.md`'s link to `../tf_infra/README.md` resolves only inside a live environment, never on GitHub. Lab 02 carries the `<FILL-IN-...>` tfvars example inline. Pass the directory to KubeOne as `kubeone <cmd> -t /training/tf_infra` (KubeOne calls `terraform output -json` itself).
- **`training-application-values.yaml`** — Helm values for the demo app. Several labs mutate `deployment.replicas`, `ingress.enabled`, `ingress.domain`, `persistMetaInfo`.
- **`09_helm-releases/cluster-issuer.yaml`** — Let's Encrypt ClusterIssuer; trainees `sed` in their email.
- **`13_backup-cluster/backups-restic.yaml`** — restic backup addon manifest.
- **`.secrets/`** (gitignored) — `gcp` / `gcp.pub` SSH keypair, `gcp-service-account.json`, and the trainer-supplied `environment.sh`.
- **`.99_todos/`** — internal trainer notes, not labs. `.99_todos/12_backup-user-data/` holds the retired velero lab and its `storageclass.yaml`.

## Repo Tooling for Claude

- **`.claude/settings.json`** denies `Read`/`Glob` on `.secrets/**`. Treat that as hard: the directory holds the SSH keypair, the gcp service-account JSON and the trainer's `environment.sh`.
- **`.claude/skills/`** ships three project skills:
  - `md-linter` — prose typos/grammar in the lab READMEs, code blocks explicitly out of scope.
  - `code-linter` — the inverse: code blocks, YAML and `/training` path correctness, prose out of scope.
  - `secrets-remover` — sweeps for anything that must not reach GitHub.
- **Both linters claim the bare `lint` trigger**, and their scopes are disjoint. On a bare `lint` ask which one is meant (or run both) rather than guessing — picking one silently leaves half the repo unchecked.
- Both linters treat `TODO`, `XXXXX` and `TODO-STUDENT-EMAIL@...` as intentional placeholders and leave them alone; both are also barred from reading `.secrets/` and `.99_todos/`. `md-linter` additionally must not "correct" `LetsEncrypt` — that edit was rejected before.

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
- **`README.md`'s `docker run` mount is wrong in two ways.** `-v $(PWD)/..:/training` was copied from `container-image/makefile`, where `$(PWD)` is Make expansion and `..` correctly means the repo root. In the README it is bash, run from the directory the trainee just cloned *into*, so `..` points one level too high. And `$(PWD)` is command substitution there — it only resolves because macOS's case-insensitive filesystem maps `PWD` to `/bin/pwd`; on Linux it expands to nothing and the mount becomes `/..:/training`. Should be `$(pwd)/advanced-operations-of-kubernetes-with-kubeone`.
- **The image tag is duplicated** in `container-image/makefile` (`IMAGE_TAG`) and `README.md`, with no mechanism keeping them in sync. `.devcontainer/devcontainer.json` pins a third, older tag (`1.0.0`).
- **`.devcontainer/devcontainer.json`** uses the deprecated `terminal.integrated.shell.linux`, has a `.gititnore` typo in `files.exclude`, and its settings have diverged from `container-image/vscode_settings.json`. Both files are needed — code-server reads `/root/.vscode/User/settings.json`, the VS Code Server in a devcontainer reads `~/.vscode-server/data/...` — but they must be kept in sync.
