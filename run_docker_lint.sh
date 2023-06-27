#!/usr/bin/env bash

echo "running Dockerfile lint locally..."

docker run --rm -it \
  -v "$(pwd)":/build \
  --workdir /build \
  hadolint/hadolint:v2.12.0-alpine hadolint Dockerfile

echo "successfully ran Dockerfile lint..."
