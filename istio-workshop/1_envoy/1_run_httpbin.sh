#!/bin/bash

echo
echo "docker run -it --rm \\ "
echo "  --name httpbin \\ "
echo "  -p 8000:8000 \\ "
echo "  httpbin:latest "
echo
echo
echo "open http://localhost:8000"
echo

docker run -it --rm \
  --name httpbin \
  -p 8000:8000 \
  httpbin:latest

