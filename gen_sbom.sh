#!/usr/bin/env bash
set -e

source './gen_sbom_functions.sh'

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