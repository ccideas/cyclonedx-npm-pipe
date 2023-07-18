#!/usr/bin/env bats

# shellcheck disable=SC2030,SC2031,SC2317
# SC2030 (info): Modification of NPM_SHORT_PURLS is local (to subshell caused by @bats test)
# SC2031 (info): NPM_OUTPUT_FORMAT was modified in a subshell. That change might be lost.
# SC2317 (info): Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
# None of the above checks are suitable for the bats framework

# file under test
load '../gen_sbom_functions.sh'

#--------------------------------------------------------------------------------
#---------------------------------Function Mocks---------------------------------
#--------------------------------------------------------------------------------

# don't actually call the npx command when running tests
cyclonedx-npm() {
  echo "mock of cyclonedx-npm"
}

generate_cyclonedx_sbom_for_npm_project() {
  echo "mock of generate_cyclonedx_sbom_for_npm_project()"
}

#--------------------------------------------------------------------------------
#---------------------------------------Tests------------------------------------
#--------------------------------------------------------------------------------

@test "Create output directory - output dir does not exist" {
  run check_output_directory

  EXPECTED_OUTPUT_DIR="sbom_output"

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "creating ${EXPECTED_OUTPUT_DIR}" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - output dir does exist" {
  EXPECTED_OUTPUT_DIR="sbom_output"
  mkdir "${EXPECTED_OUTPUT_DIR}"

  run check_output_directory

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "${EXPECTED_OUTPUT_DIR} already exists" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - custom dir - output dir does not exist" {
  export OUTPUT_DIRECTORY="build"
  run check_output_directory

  EXPECTED_OUTPUT_DIR=${OUTPUT_DIRECTORY}

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "creating ${EXPECTED_OUTPUT_DIR}" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - custom dir - output dir does exist" {
  export OUTPUT_DIRECTORY="build"
  EXPECTED_OUTPUT_DIR=${OUTPUT_DIRECTORY}
  mkdir "${EXPECTED_OUTPUT_DIR}"

  run check_output_directory

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "${EXPECTED_OUTPUT_DIR} already exists" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - no BITBUCKET_REPO_SLUG" {
  unset BITBUCKET_REPO_SLUG
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY
  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to sbom_output/sbom.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with BITBUCKET_REPO_SLUG" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to sbom_output/${BITBUCKET_REPO_SLUG}.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with SBOM_FILENAME" {
  export SBOM_FILENAME="this_is_my_filename"
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to sbom_output/${SBOM_FILENAME}.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with a set output format" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  export NPM_OUTPUT_FORMAT="xml"

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to sbom_output/${BITBUCKET_REPO_SLUG}.xml" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - custom dir - with a set output format" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  export NPM_OUTPUT_FORMAT="xml"
  export OUTPUT_DIRECTORY="build"

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/${BITBUCKET_REPO_SLUG}.xml" ]
  [ "$status" -eq 0 ]
}

@test "Verify help function" {
  run help

  [ "${lines[0]}" = "Generates a CycloneDX sBOM file for the given project" ]
  [ "$status" -eq 0 ]
}

@test "Verify unknown project format" {
  run unknown_project_format

  [ "${lines[0]}" = "ERROR: unknown project format" ]
  [ "${lines[1]}" = "currently only node/npm based projects are supported" ]
  [ "$status" -eq 1 ]
}

@test "Generate sBOM for node/npm based project" {
  # Create a temporary package.json file
  touch "package.json"

  run generate_cyclonedx_sbom

  [ "${lines[0]}" = "package.json file found. Generating sBOM for node/npm based projects" ]
  [ "$status" -eq 0 ]

  # Clean up the temporary package.json file
  rm "package.json"
}

@test "Generate sBOM for unknown project type" {
  run generate_cyclonedx_sbom

  [ "${lines[0]}" = "ERROR: unknown project format" ]
  [ "${lines[1]}" = "currently only node/npm based projects are supported" ]
  [ "$status" -eq 1 ]
}

@test "Verify boolean cmd switches - true" {
  export NPM_PACKAGE_LOCK_ONLY="true"
  export IGNORE_NPM_ERRORS="true"
  export NPM_FLATTEN_COMPONENTS="true"
  export NPM_SHORT_PURLS="true"
  export NPM_OUTPUT_REPRODUCIBLE="true"

  output=$(generate_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--package-lock-only"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --package-lock-only switch"
  fi

  if [[ ${output} != *"--ignore-npm-errors"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --ignore-npm-errors switch"
  fi

  if [[ ${output} != *"--flatten-components"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --flatten-components switch"
  fi

  if [[ ${output} != *"--short-PURLs"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --short-purls"
  fi

  if [[ ${output} != *"--output-reproducible"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --output-reproducible switch"
  fi

  return ${FAILURE_DETECTED}
}

@test "Verify boolean cmd switches - mixed" {
  export NPM_PACKAGE_LOCK_ONLY="false"
  export IGNORE_NPM_ERRORS="true"
  export NPM_FLATTEN_COMPONENTS="true"
  export NPM_SHORT_PURLS="false"

  output=$(generate_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  # test for switches which should be set
  if [[ ${output} != *"--ignore-npm-errors"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --ignore-npm-errors switch"
  fi

  if [[ ${output} != *"--flatten-components"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --flatten-components switch"
  fi

  # verify switches which should not be set
  if [[ ${output} == *"--package-lock-only"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: found --package-lock-only switch -- this should not be set"
  fi

  if [[ ${output} == *"--short-PURLs"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: found --short-purls -- this should not be set"
  fi

  if [[ ${output} == *"--output-reproducible"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: found --output-reproducible switch -- this should not be set"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify switches with params" {
  export NPM_SPEC_VERSION="1.4"
  export NPM_MC_TYPE="application"
  export NPM_OMIT="dev"
  export NPM_OUTPUT_FORMAT="json"

  output=$(generate_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--spec-version 1.4"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --spec-version was not properly set"
  fi

  if [[ ${output} != *"--mc-type application"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --mc-type was not properly set"
  fi

  if [[ ${output} != *"--omit dev"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --omit was not successfully set"
  fi

  if [[ ${output} != *"--output-format json"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --output-format was not successfully set"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify cyclonedx-npm is installed" {
  export CYCLONEDX_NPM_VERSION="1.12.1"
  run verify_cyclonedx

  [ "${lines[1]}" = "version 1.12.1 of cyclonedx-npm is installed" ]
}

@test "Verify cyclonedx-npm is installed - invalid version" {
  unset CYCLONEDX_NPM_VERSION
  run verify_cyclonedx
  [ "$status" -eq 1 ]
}


#--------------------------------------------------------------------------------
#--------------------------Setup and Teardown functions--------------------------
#--------------------------------------------------------------------------------

# Custom teardown function
teardown() {
  echo "running test cleanup"

  # remove sbom_output if it exists
  if [ -d "sbom_output" ]; then
    echo "removing sbom_output directory"
    rm -rf sbom_output
  fi

  # remove package.json if it exists
  if [ -f "package.json" ]; then
    echo "removing package.json"
    rm "package.json"
  fi

  # remove build if it exists
  if [ -d "build" ]; then
    echo "removing build directory"
    rm -rf build
  fi
}
