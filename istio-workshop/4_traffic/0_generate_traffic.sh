#!/bin/bash

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_HOST
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export INGRESS_PORT

# export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
# export SECURE_INGRESS_PORT

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo
echo "The product page is :"
echo "http://$GATEWAY_URL/productpage"
echo


# GET SOME TRAFFIC
#while true; do curl -o /dev/null -s -w "%{http_code}\n" http://$GATEWAY_URL/productpage ; sleep 1; done;

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Or use slapper
echo "GET http://$GATEWAY_URL/productpage" > "$script_dir"/target

slapper -targets "$script_dir"/target -minY 1ms -maxY 1000ms -rate 50
