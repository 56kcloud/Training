#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Introduce delay
kubectl apply -f "$script_dir"/1_virtual-service-ratings-test-delay.yaml
