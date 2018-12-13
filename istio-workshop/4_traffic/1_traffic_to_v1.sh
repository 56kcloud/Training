#!/bin/bash
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo
echo BEFORE
echo
kubectl get virtualservices
echo
echo "Switching all to v1"
echo
kubectl apply -f "$script_dir"/1_virtual-service-all-v1.yaml

echo
echo AFTER
echo

kubectl get virtualservices
