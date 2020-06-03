#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

## kill all port-forward
pkill kubectl

kubectl delete -f "$script_dir"/install_istio.yaml
