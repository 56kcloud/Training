#!/bin/bash

echo
echo "Open the file 2_gw.sh"
echo

exit 1

function get_pod_name {
  name="$1"
  ns="${2:-"istio-system"}"
  kubectl get pod -n "$ns" -l app="$name" -o jsonpath='{.items[0].metadata.name}'
}


kubectl -n istio-system exec -it "$(get_pod_name istio-ingressgateway istio-system)" bash

curl localhost:15000/help
curl localhost:15000/stats
curl localhost:15000/listeners
curl localhost:15000/clusters
curl localhost:15000/server_info


