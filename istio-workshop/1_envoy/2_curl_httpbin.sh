#!/bin/bash

echo
echo "docker run -it --rm \\ "
echo "  --link httpbin \\ "
echo "  tutum/curl \\ "
echo "  curl -X GET http://httpbin:8000/headers "
echo

docker run -it --rm \
  --link httpbin \
  tutum/curl \
  curl -X GET http://httpbin:8000/headers
