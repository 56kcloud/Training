#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

kubectl -n istio-system describe configmap istio-sidecar-injector

kubectl -n istio-system get configmap istio-sidecar-injector -o=jsonpath='{.data.config}' > "$script_dir"/inject-config.yaml

