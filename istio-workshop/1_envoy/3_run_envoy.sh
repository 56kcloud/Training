#!/bin/bash

echo
echo "docker run -it --rm \\ "
echo "    --name sidecar_proxy \\ "
echo "    --link httpbin \\ "
echo "    envoyproxy/envoy:v1.8.0 envoy "
echo

docker run -it --rm \
    --name sidecar_proxy \
    --link httpbin \
    envoyproxy/envoy:v1.8.0 envoy
