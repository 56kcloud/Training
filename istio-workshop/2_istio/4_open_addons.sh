#!/bin/bash

function get_pod_name {
  name="$1"
  kubectl get pod -n istio-system -l app="$name" -o jsonpath='{.items[0].metadata.name}'
}

function get_app_ports {
  name=${1:?"need a name"}
  ns=${2:-"istio-system"}
  kubectl get -n "$ns" pod -l app="$1" -o json | jq -r '.items[] | .spec.containers[] | .ports[]? | .containerPort'
}

function activate_addon {
  name=${1:?"need a name"}
  port=${2:-$(get_app_port "$name")}
  ns=${3:-"istio-system"}

  echo
  echo "port forwarding $name on port $port"
  echo
  kubectl port-forward -n "$ns" "$(get_pod_name $name)" "$port":"$port" &
  sleep 3
  open http://localhost:"$port"
}

activate_addon jaeger 16686
activate_addon grafana 3000
activate_addon prometheus 9090
activate_addon kiali 20001

# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 # GRAFANA
# open http://localhost:3000/dashboard/db/istio-dashboard  # browser to graphana

# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 # PROMETHEUS
# open http://localhost:9090/graph

# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088 # service graph
# open http://localhost:8088/force/forcegraph.html # browser to service graph

# kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 # KIALI
# Open http://localhost:20001 # admin/admin
