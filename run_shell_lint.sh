#!/usr/bin/env bash

echo "running shellcheck locally..."

docker run --rm -it \
  -v "$(pwd)":/build \
  --workdir /build \
  koalaman/shellcheck-alpine:v0.9.0 shellcheck -x ./*.sh ./**/*.bats

echo "shellcheck complete..."