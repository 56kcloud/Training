#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# DEPLOY THE BOOKINFO APP
kubectl apply -f "$script_dir"/1_bookinfo.yaml

# Apply ingress gateway
kubectl apply -f "$script_dir"/1_bookinfo-gateway.yaml

# set routing rules
kubectl apply -f "$script_dir"/1_destination-rule-all-mtls.yaml    # with mTLS
