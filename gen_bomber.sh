#!/usr/bin/env bash
set -e

# Statics
BOMBER_SWITCHES=()
OUTPUT_DIRECTORY="sbom_output"

## purpose: scans generated sbom with bomber to report vulnerabilities

verify_bomber() {
  echo "verifying bomber is installed"

  if [[ "${BOMBER_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "version ${BOMBER_VERSION} of bomber is installed"
  else
    echo "ERROR: cannot validate version of bomber. Verify package is installed"
    exit 1
  fi
}

check_sbom() {
  echo "checking if sbom file exists"

  if [[ ! -e "${OUTPUT_FILENAME}" ]]; then
    echo "ERROR: cannot find sbom file to scan. Verify file was generated successfully"
    echo 1
  fi
}

generate_bomber_switches() {
  if [ "${BOMBER_DEBUG}" = "true" ]; then
    BOMBER_SWITCHES+=('--debug')
  fi

  if [ -n "${BOMBER_IGNORE_FILE}" ]; then
    BOMBER_SWITCHES+=("--ignore-file" "${BOMBER_IGNORE_FILE}")
  fi

  if [ -n "${BOMBER_PROVIDER}" ]; then
    BOMBER_SWITCHES+=("--provider" "${BOMBER_PROVIDER}")
  fi

  if [ -n "${BOMBER_PROVIDER_TOKEN}" ]; then
    BOMBER_SWITCHES+=("--token" "${BOMBER_PROVIDER_TOKEN}")
  fi

  if [ -n "${BOMBER_PROVIDER_USERNAME}" ]; then
    BOMBER_SWITCHES+=("--username" "${BOMBER_PROVIDER_USERNAME}")
  fi

  if [ -n "${BOMBER_OUTPUT_FORMAT}" ]; then
    BOMBER_SWITCHES+=("--output" "${BOMBER_OUTPUT_FORMAT}")
  fi

  echo "the following bomber switches will be used"
  echo "${BOMBER_SWITCHES[@]}"
}

run_bomber_scan() {
  bomber scan "${BOMBER_SWITCHES[@]}" "${OUTPUT_FILENAME}"
  cp ./*-bomber-results.* "${OUTPUT_DIRECTORY}"
}
