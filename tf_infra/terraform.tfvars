project                                 = "<FILL-IN-YOUR-GOOGLE-PROJECT-ID>" # you can get the info via `echo $GOOGLE_PROJECT`
cluster_name                            = "<FILL-IN-CLUSTER-NAME>"           # eg "k1-training"
region                                  = "europe-west3"
ssh_public_key_file                     = "/workspaces/advanced-operations-of-kubernetes-with-kubeone/.secrets/google_compute_engine.pub"
ssh_private_key_file                    = "/workspaces/advanced-operations-of-kubernetes-with-kubeone/.secrets/google_compute_engine"
control_plane_vm_count                  = 1
control_plane_target_pool_members_count = 1
initial_machinedeployment_replicas      = 1
