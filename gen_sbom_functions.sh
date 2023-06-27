#!/usr/bin/env bash
set -e

# Statics
OUTPUT_DIRECTORY="sbom_output"
SWITCHES=()

## purpose: generate a CycloneDX sBOM

check_output_directory() {
  echo "checking if output directory exists"
  if [ ! -d "${OUTPUT_DIRECTORY}" ]; then
    echo "creating output dir"
    mkdir "${OUTPUT_DIRECTORY}"
  else
    echo "${OUTPUT_DIRECTORY} already exists"
  fi
}

set_sbom_filename() {
  if [ -z "${BITBUCKET_REPO_SLUG}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/sbom"
  else
    OUTPUT_FILENAME="${OUTPUT_DIRECTORY}/${BITBUCKET_REPO_SLUG}"
  fi

  if [ -n "${NPM_OUTPUT_FORMAT}" ]; then
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.${NPM_OUTPUT_FORMAT}"
  else
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.json"
  fi

  echo "sBOM will be written to ${OUTPUT_FILENAME}"
  SWITCHES+=("--output-file" "${OUTPUT_FILENAME}")
}

help() {
  echo "Generates a CycloneDX sBOM file for the given project"
}

generate_cyclonedx_sbom_for_npm_project() {
  echo "installing cyclonedx/cyclonedx-npm"
  npx --yes --package @cyclonedx/cyclonedx-npm --call exit

  generate_switches
  npx @cyclonedx/cyclonedx-npm "${SWITCHES[@]}"
}

generate_switches() {
  if [ "${NPM_PACKAGE_LOCK_ONLY}" = true ]; then
    SWITCHES+=('--package-lock-only')
  fi

  # for legacy purposes IGNORE_NPM_ERRORS is not being appended with NPM_
  if [ "${IGNORE_NPM_ERRORS}" = true ]; then
    SWITCHES+=('--ignore-npm-errors')
  fi

  if [ "${NPM_FLATTEN_COMPONENTS}" = true ]; then
    SWITCHES+=('--flatten-components')
  fi

  if [ "${NPM_SHORT_PURLS}" = true ]; then
    SWITCHES+=('--short-PURLs')
  fi

  if [ "${NPM_OUTPUT_REPRODUCIBLE}" = true ]; then
    SWITCHES+=('--output-reproducible')
  fi

  if [ -n "${NPM_SPEC_VERSION}" ]; then
    SWITCHES+=("--spec-version" "${NPM_SPEC_VERSION}")
  fi

  if [ -n "${NPM_MC_TYPE}" ]; then
    SWITCHES+=("--mc-type" "${NPM_MC_TYPE}")
  fi

  if [ -n "${NPM_OMIT}" ]; then
    SWITCHES+=("--omit" "${NPM_OMIT}")
  fi

  if [ -n "${NPM_OUTPUT_FORMAT}" ]; then
    SWITCHES+=("--output-format" "${NPM_OUTPUT_FORMAT}")
  fi

  echo "the following switches will be used"
  echo "${SWITCHES[@]}"
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
