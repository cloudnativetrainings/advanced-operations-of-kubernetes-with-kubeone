#!/bin/bash

source /root/.trainingrc

# machines
gcloud -q compute instances delete \
  $PREFIX-master-0 $PREFIX-master-1 $PREFIX-master-2 \
  $PREFIX-worker-0 $PREFIX-worker-1 $PREFIX-worker-2

# networking
gcloud -q compute addresses delete $PREFIX-magicless-ip-address

# firewall
gcloud -q compute firewall-rules delete \
  $PREFIX-magicless-internal \
  $PREFIX-magicless-inbound

# routes if created
for x in {0..2}; do
  gcloud compute routes delete -q $PREFIX-k8s-pod-route-192-168-1${x}-0-24
done

# networks
gcloud -q compute networks subnets delete $PREFIX-magicless-subnet
gcloud -q compute networks delete $PREFIX-magicless-vpc
