#!/bin/bash

# script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# find "$script_dir" -name '99_remove.sh' | xargs bash

NAMESPACE=${1:-"default"}

protos=( destinationrules virtualservices gateways )
for proto in "${protos[@]}"; do
  for resource in $(istioctl get -n "${NAMESPACE}" "$proto" | awk 'NR>1{print $1}'); do
    istioctl delete -n "${NAMESPACE}" "$proto" "$resource";
  done
done