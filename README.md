# Bitbucket Pipelines Pipe:  CycloneDX npm/node sBOM Generator

A Bitbucket Pipe which generates a CycloneDX compliant Software Bill of Materials
for a node/npm project

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
- pipe: ccideas/ccideas/cyclonedx-npm-pipe:0.1.0
  variables
    # IGNORE_NPM_ERRORS: "<boolean>" # Optional  
```
## Variables

| Variable              | Usage                                                       | Default | COMMAND |
| --------------------- | ----------------------------------------------------------- | ------- | ------- |
|IGNORE_NPM_ERRORS| Used to ignore any npm errors when generating the report. Typically used if you use npm install --force to install dependencies | false |
## Details

Generates a CycloneDX compliant Software Bill of Materials
for a node/npm project. The generated sBOM will be created in the
sbom-output directoy and be named `${BITBUCKET_REPO_SLUG}-sbom.json`

## Prerequisites

npm dependencies must be installed first. It is advised to install npm dependencies
in one step then archive them, so they can be read by the pipe. See the example below.

## Examples

```yaml
pipeline:
  default:
    - stage:
        name: Generate CycloneDX sBOM
        steps:
          - step:
              name: Install Dependencies
              caches:
                - node
              script:
                - npm install
          - step:
              name: Build sBOM
              caches:
                - node
              script:
                - pipe: ccideas/cyclonedx-npm-pipe:0.1.0
              artifacts:
                - sbom-output/**
```

## Support

If you'd like help with this pipe, or you have an issue, or a feature request, [let us know](https://github.com/ccideas/cyclonedx-npm-pipe/issues).

If you are reporting an issue, please include:

the version of the pipe
relevant logs and error messages
steps to reproduce
