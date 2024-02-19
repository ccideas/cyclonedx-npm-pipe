#!/usr/bin/env bash

echo "building docker image locally..."

docker build \
  --no-cache \
  --build-arg ARCH=arm64 \
  --tag cyclonedx-npm-pipe:dev \
  .

echo "finished building docker image..."