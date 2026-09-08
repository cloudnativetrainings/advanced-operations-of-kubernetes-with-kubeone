cluster_name                            = "hubert-04-cluster"
project                                 = "k1-del-codespaces"
region                                  = "europe-west3"
ssh_public_key_file                     = "/training/.secrets/gcp.pub"
ssh_private_key_file                    = "/training/.secrets/gcp"
control_plane_vm_count                  = 3
control_plane_target_pool_members_count = 3
initial_machinedeployment_replicas      = 1
