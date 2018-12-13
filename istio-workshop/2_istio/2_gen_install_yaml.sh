#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

ISTIO_VERSION="1.0.4"

helm template "$script_dir/charts_$ISTIO_VERSION" \
  --name istio \
  --namespace istio-system \
  --set global.crds=false \
  --set sidecarInjectorWebhook.enabled=true \
  --set prometheus.enabled=true \
  --set grafana.enabled=true \
  --set servicegraph.enabled=true \
  --set tracing.enabled=true \
  --set kiali.enabled=true \
  --set kiali.tag=v0.10.1 \
  --set mtls.enabled=true \
  > "$script_dir"/install_istio.yaml
