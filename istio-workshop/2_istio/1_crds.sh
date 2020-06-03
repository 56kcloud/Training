#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

kubectl apply -f "$script_dir"/1_crds.yaml
