#!/usr/bin/env bash

echo "running cyclonedx-npm-pipe locally..."

docker run --rm -it \
  -v "$(pwd)":/build \
  --workdir /build \
  --env NPM_PACKAGE_LOCK_ONLY=true \
  --env NPM_FLATTEN_COMPONENTS=true \
  --env NPM_SHORT_PURLS=true \
  --env NPM_OUTPUT_REPRODUCIBLE=false \
  --env NPM_MC_TYPE=application \
  --env IGNORE_NPM_ERRORS=true \
  --env SCAN_SBOM_WITH_BOMBER=true \
  --env BOMBER_OUTPUT_FORMAT="html" \
  --env BOMBER_DEBUG=false \
  cyclonedx-npm-pipe:dev

echo "successfully ran cyclonedx-npm-pipe locally..."

# removes --env switches
#--env NPM_OUTPUT_FORMAT=xml \
#--env NPM_SPEC_VERSION=1.3 \
#--env NPM_OMIT=dev \