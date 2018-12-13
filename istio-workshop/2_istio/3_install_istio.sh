#!/bin/bash

kubectl create namespace istio-system

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

kubectl apply -f "$script_dir"/install_istio.yaml

# allow side-car injection
kubectl label namespace default istio-injection=enabled
