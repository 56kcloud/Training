#!/bin/bash


echo
echo "docker run -it --rm \\ "
echo "  --link sidecar_proxy \\ "
echo "  tutum/curl \\ "
echo "  curl -X GET -w \"%{http_code}\\n\" http://sidecar_proxy:15001/status/500 "
echo
echo ">> endpoint will return 500"
echo

# create error
docker run -it --rm \
  --link sidecar_proxy \
  tutum/curl \
  curl -X GET -w "%{http_code}\\n" http://sidecar_proxy:15001/status/500
