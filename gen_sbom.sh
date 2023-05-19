#!/usr/bin/env bash
set -e

## purpose: generate a CycloneDX sBOM

OUTPUT_DIRECTORY="output"

if [ ! -d "${OUTPUT_DIRECTORY}" ]; then
  mkdir "${OUTPUT_DIRECTORY}"
fi

if [ -z ${BITBUCKET_REPO_SLUG} ]; then
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/sbom.json"
else
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/${BITBUCKET_REPO_SLUG}.json"
fi

SWITCHES_GLOBAL="--output-file ${OUTPUT_FILENAME} --short-PURLs"

help() {
  echo "Generates a CycloneDX sBOM file for the given project"
}

gen_sbom_for_npm_project() {
  SWITCHES_NPM=""

  npx --yes --package @cyclonedx/cyclonedx-npm --call exit
  npx @cyclonedx/cyclonedx-npm ${SWITCHES_NPM} ${SWITCHES_GLOBAL}
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  help
  exit 0
fi

if [ -f "package.json" ]; then
  echo "package.json file found. Generating sBOM for node/npm based projects"
  gen_sbom_for_npm_project
else
  echo "ERROR: unknown project format"
  echo "currently only node/npm based projects are supported"
  exit 1
fi
