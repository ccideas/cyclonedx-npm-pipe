#!/usr/bin/env bash
set -e

if [ -z "${GEN_SBOM_SCRIPT_LOCATION}" ]; then
  source "./gen_sbom_functions.sh"
  source "./gen_bomber.sh"
else
  source "${GEN_SBOM_SCRIPT_LOCATION}/gen_sbom_functions.sh"
  source "${GEN_SBOM_SCRIPT_LOCATION}/gen_bomber.sh"
fi

#--------------------------------------------------------------------------------
#----------------------------------Program Start---------------------------------
#--------------------------------------------------------------------------------

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  help
  exit 0
fi

check_output_directory
set_sbom_filename
generate_cyclonedx_sbom

if [ "${SCAN_SBOM_WITH_BOMBER}" == "true" ]; then
  echo "scanning sbom via bomber"
  BOMBER_VERSION=$(bomber --version | sed 's/^bomber version //')
  verify_bomber
  check_sbom
  generate_bomber_switches
  run_bomber_scan
fi
