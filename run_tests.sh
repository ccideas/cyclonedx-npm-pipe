#!/usr/bin/env bash

echo "running unit tests locally..."

docker run --rm -it \
  -v "$(pwd)":/build \
  --workdir /build \
  bats/bats:1.9.0 test/gen_sbom.bats --timing

echo "unit test run complete..."