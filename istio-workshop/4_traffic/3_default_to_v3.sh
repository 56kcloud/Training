#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# all v3 but user jason to v2
kubectl apply -f "$script_dir"/3_virtual-service-reviews-jason-v2-v3.yaml

