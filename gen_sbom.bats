#!/usr/bin/env bats

load './gen_sbom.sh'

# Mock the npx command
function npx() {
  echo "Mocked npx command executed with arguments: $@"
}

@test "Check if the output directory is created" {
  run check_output_directory
  [ -d "$OUTPUT_DIRECTORY" ]
  [ "$status" -eq 0 ]
}

@test "Check if help function works" {
  run help
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Generates a CycloneDX sBOM file for the given project" ]
}

@test "Check if error is thrown for unknown project format" {
  touch "README.md"
  run unknown_project_format
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "ERROR: unknown project format" ]
  [ "${lines[1]}" = "currently only node/npm based projects are supported" ]
}

@test "Check if sBOM is generated for node/npm project with custom package.json" {
  # Create a temporary package.json file with custom content
  echo '{"name": "custom-package", "version": "1.0.0"}' > "custom-package.json"

  # Store the original package.json filename
  original_package_json="package.json"

  # Set the custom package.json filename
  export PACKAGE_JSON="custom-package.json"

  # Run the generate_sbom_for_npm_project function
  run gen_sbom_for_npm_project

  # Assert the expected behavior
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Mocked call to gen_sbom_for_npm_project" ]

  # Restore the original package.json filename
  export PACKAGE_JSON="$original_package_json"

  # Remove the temporary package.json file
  rm "custom-package.json"
}

# Custom teardown function
teardown() {
  echo "running post test cleanup"
  if [ -f "custom-package.json" ]; then
    echo "removing custom-package.json"
    rm "custom-package.json"
  fi

  if [ -d "sbom_output" ]; then
    echo "removing sbom_output directory"
    rm -rf sbom_output
  fi
}
