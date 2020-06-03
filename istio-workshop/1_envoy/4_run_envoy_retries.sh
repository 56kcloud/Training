#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

config_file="$script_dir"/4_run_envoy_retries.yaml

cat "$config_file"

echo
echo
read -rp "Press enter to run envoy" continue
echo
echo
echo
echo "docker run -it --rm \\ "
echo "  --name sidecar_proxy \\ "
echo "  --link httpbin \\ "
echo "  -v $config_file:/etc/envoyconfig.yaml \\ "
echo "  -p 15001:15001 \\ "
echo "  envoyproxy/envoy:v1.8.0 \\ "
echo "  envoy -c /etc/envoyconfig.yaml "
echo
echo
echo

docker run -it --rm \
  --name sidecar_proxy \
  --link httpbin \
  -v "$config_file":/etc/envoyconfig.yaml \
  -p 15001:15001 \
  -p 15000:15000 \
  envoyproxy/envoy:v1.8.0 \
  envoy -c /etc/envoyconfig.yaml
