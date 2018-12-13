#!/bin/bash


echo
echo "Open the file 2_gw.sh"
echo

exit 1


function get_pod_name {
  name="$1"
  ns="${2:-"default"}"
  kubectl get pod -n "$ns" -l app="$name" -o jsonpath='{.items[0].metadata.name}'
}

kubectl exec -it "$(get_pod_name productpage default)" -c istio-proxy sh

ps aux

cat /etc/istio/proxy/envoy-rev0.json
