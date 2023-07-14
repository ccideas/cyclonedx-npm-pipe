#!/usr/bin/env bats

# shellcheck disable=SC2030,SC2031,SC2317
# SC2030 (info): Modification of <VARIABLE> is local (to subshell caused by @bats test)
# SC2031 (info): <VARIABLE> was modified in a subshell. That change might be lost.
# SC2317 (info): Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
# None of the above checks are suitable for the bats framework

# file under test
load '../gen_bomber.sh'

#--------------------------------------------------------------------------------
#---------------------------------Function Mocks---------------------------------
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
#---------------------------------------Tests------------------------------------
#--------------------------------------------------------------------------------

@test "Verify bomber is installed" {
  # this is just a fake version. Its only used to verify the semver parsing logic
  export BOMBER_VERSION="0.2.4"
  run verify_bomber

  [ "${lines[1]}" = "version 0.2.4 of bomber is installed" ]
}

@test "Verify bomber is installed - invalid version" {
  unset BOMBER_VERSION
  run verify_bomber

  [ "$status" -eq 1 ]
}

@test "Verify bomber is installed - not installed" {
  BOMBER_VERSION="zsh: command not found: bomber"
  run verify_bomber

  [ "$status" -eq 1 ]
}

@test "Verify sbom exists - sbom does exist" {
  mkdir "sbom_output"
  OUTPUT_FILENAME="sbom_output/testsbom.json"
  touch "${OUTPUT_FILENAME}"

  run check_sbom

  [ "$status" -eq 0 ]
}

@test "Verify switches with params" {
  export BOMBER_IGNORE_FILE=".bomberignore"
  export BOMBER_PROVIDER="ossindex"
  export BOMBER_PROVIDER_TOKEN="1234567890"
  export BOMBER_PROVIDER_USERNAME="ossindexusername"
  export BOMBER_OUTPUT_FORMAT="html"

  output=$(generate_bomber_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--ignore-file .bomberignore"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --ignore-file was not properly set"
  fi

  if [[ ${output} != *"--provider ossindex"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --provider was not properly set"
  fi

  if [[ ${output} != *"--token 1234567890"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --token was not successfully set"
  fi

  if [[ ${output} != *"--username ossindexusername"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --username was not successfully set"
  fi

  if [[ ${output} != *"--output html"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --output was not successfully set"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify boolean cmd switches - true" {
  export BOMBER_DEBUG="true"

  output=$(generate_bomber_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--debug"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --debug switch"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify boolean cmd switches - false" {
  export BOMBER_DEBUG="false"

  output=$(generate_bomber_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} == *"--debug"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: found --debug switch when it was set to false"
  fi

  return "${FAILURE_DETECTED}"
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
}
