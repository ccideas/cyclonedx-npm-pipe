#!/usr/bin/env bats

# file under test
load '../gen_sbom_functions.sh'

#--------------------------------------------------------------------------------
#---------------------------------Function Mocks---------------------------------
#--------------------------------------------------------------------------------

# don't actually call the npx command when running tests
npx() {
  echo "mock of npx call"
}

#--------------------------------------------------------------------------------
#---------------------------------------Tests------------------------------------
#--------------------------------------------------------------------------------

@test "Create output directory - output dir does not exist" {
  run check_output_directory

  [ -d "$OUTPUT_DIRECTORY" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - output dir does exist" {
  mkdir "${OUTPUT_DIRECTORY}"

  run check_output_directory

  [ -d "$OUTPUT_DIRECTORY" ]
  [ "${lines[1]}" = "${OUTPUT_DIRECTORY} already exists" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - no BITBUCKET_REPO_SLUG" {
  run set_sbom_filename

  [ "${lines[0]}" = "sBOM will be written to sbom_output/sbom.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with BITBUCKET_REPO_SLUG" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"

  run set_sbom_filename

  [ "${lines[0]}" = "sBOM will be written to sbom_output/${BITBUCKET_REPO_SLUG}.json" ]
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

@test "Generate node/npm sbom" {
  run generate_cyclonedx_sbom_for_npm_project

  [ "${lines[0]}" = "installing cyclonedx/cyclonedx-npm" ]
  [ "${lines[2]}" = "generating cyclonedx sbom" ]
  [ "$status" -eq 0 ]
}

@test "Generate node/npm sbom - ignore npm errors" {
  export IGNORE_NPM_ERRORS="true"

  run generate_cyclonedx_sbom_for_npm_project

  # Assert the expected behavior
  [ "${lines[0]}" = "installing cyclonedx/cyclonedx-npm" ]
  [ "${lines[7]}" = "generating sbom by ignoring npm errors" ]
  [ "$status" -eq 0 ]
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
}
