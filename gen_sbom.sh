#!/usr/bin/env bash
set -e

IGNORE_NPM_ERRORS_WARNING="WARNING: this may generate inaccurate results in the sbom, consider \
                           resolving the issue by running any of the following \
                           1. verify you are using a supported node/npm version for the project \
                           2. clean npm cache npm cache clean --force and re-run npm install \
                           3. update the conflicting dependency directly"

## purpose: generate a CycloneDX sBOM

check_output_directory() {
  echo "checking if output directory exists"
  OUTPUT_DIRECTORY="sbom_output"
  if [ ! -d "${OUTPUT_DIRECTORY}" ]; then
    mkdir "${OUTPUT_DIRECTORY}"
  fi
}

set_output_filename() {
  if [ -z "${BITBUCKET_REPO_SLUG}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/sbom.json"
  else
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/${BITBUCKET_REPO_SLUG}.json"
  fi
}

help() {
  echo "Generates a CycloneDX sBOM file for the given project"
}

generate_cyclonedx_sbom_for_npm_project() {
  SWITCHES="--output-file ${OUTPUT_FILENAME} --short-PURLs"

  echo "installing cyclonedx/cyclonedx-npm"
  npx --yes --package @cyclonedx/cyclonedx-npm --call exit

  echo "generating cyclonedx sbom"
  if [ "${IGNORE_NPM_ERRORS}" != "true" ]; then
    npx @cyclonedx/cyclonedx-npm ${SWITCHES}
  else
    echo "generating sbom by ignoring npm errors"
    echo "${IGNORE_NPM_ERRORS_WARNING}"
    npx @cyclonedx/cyclonedx-npm --ignore-npm-errors ${SWITCHES}
  fi
}

unknown_project_format() {
  echo "ERROR: unknown project format"
  echo "currently only node/npm based projects are supported"
  exit 1
}

generate_cyclonedx_sbom() {
  if [ -f "package.json" ]; then
    echo "package.json file found. Generating sBOM for node/npm based projects"
    generate_cyclonedx_sbom_for_npm_project
  else
    unknown_project_format
  fi
}

# program start

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  help
  exit 0
fi

check_output_directory
set_output_filename
generate_cyclonedx_sbom
