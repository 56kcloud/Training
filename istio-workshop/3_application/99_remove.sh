#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

kubectl delete -f "$script_dir"/1_bookinfo.yaml

kubectl delete -f "$script_dir"/1_bookinfo-gateway.yaml

kubectl delete -f 1_destination-rule-all-mtls.yaml            # with mTLS
