#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

kubectl delete -f "$script_dir"/3_virtual-service-reviews-jason-v2-v3.yaml
kubectl delete -f "$script_dir"/2_virtual-service-reviews-test-v2.yaml
kubectl delete -f "$script_dir"/1_virtual-service-all-v1.yaml
