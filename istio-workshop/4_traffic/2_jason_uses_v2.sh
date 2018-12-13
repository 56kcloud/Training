#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# set user jason to use V2
kubectl apply -f "$script_dir"/2_virtual-service-reviews-test-v2.yaml

