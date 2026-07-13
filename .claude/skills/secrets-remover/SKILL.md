---
name: secrets-remover
description: Check all files if there is any sensitive info which should not get pushed towards github. Invoke when the user says "remove secrets".
---

# Secrets remover

Check all files, except the hidden .secrets directory, if there is any sensitive info which should not be shared. For example passwords, tokens, serviceaccount.json, kubeconfig,... files.
