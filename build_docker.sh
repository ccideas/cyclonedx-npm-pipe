#!/usr/bin/env bash

echo "building docker image locally..."

docker build \
  --tag cyclonedx-npm-pipe:dev \
  .

echo "finished building docker image..."