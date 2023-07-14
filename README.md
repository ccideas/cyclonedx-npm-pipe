# Bitbucket Pipelines Pipe:  CycloneDX npm/node sBOM Generator

A Bitbucket Pipe which generates a CycloneDX compliant Software Bill of Materials
for a node/npm project. Optionally this pipe has the ability to scan the generated
CycloneDX sBOM for OSS security vulnerabilities using various tools such as 
[bomber](https://github.com/devops-kung-fu/bomber).

For obvious reason the official copy this project is hosted on [Bitbucket](https://bitbucket.org/ccideas1/cyclonedx-npm-pipe/src/main/).
In order to reach a diverse audience a copy of the repo also exists in [GitHub](https://github.com/ccideas/cyclonedx-npm-pipe).
It is recommended to submit Pull Requests to the Bitbucket copy, however submissions to either copy
will be synced.

## YAML Definition

The following is an example of a bitbucket pipeline which installs npm dependencies and caches those
dependencies in one step then uses those cached depdencies in the next step to build a CycloneDX
sBOM. The following code snip would need to be added to the `bitbucket-pipelines.yml` file

```yaml
pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm install
          - npm test
    - step:
        name: Gen CycloneDX sBom
        caches:
          - node
        script:
          - pipe: docker://ccideas/cyclonedx-npm-pipe:prod-1.0.37
            variables:
              IGNORE_NPM_ERRORS: 'true' # optional
              NPM_SHORT_PURLS: 'true' # optional
              NPM_OUTPUT_FORMAT: 'json' # optional
              NPM_PACKAGE_LOCK_ONLY: 'false' # optional
              SCAN_SBOM_WITH_BOMBER: 'true' # optional
              BOMBER_OUTPUT_FORMAT: 'html'
        artifacts:
          - sbom_output/*
```
## Variables

| Variable                  | Usage                                                               | Options                         | Default       |
| ---------------------     | -----------------------------------------------------------         | -----------                     | -------       |
| IGNORE_NPM_ERRORS         | Used to ignore any npm errors when generating the report            | true, false                     | false         |
| NPM_FLATTEN_COMPONENTS    | Used to specify if the components should be flattened               | true, false                     | false         |
| NPM_SHORT_PURLS           | Used to specify if qualifiers from PackageURLs should be shortened  | true, false                     | false         |
| NPM_OUTPUT_REPRODUCIBLE   | Used to specify if the output should be reproducible                | true, false                     | false         |
| NPM_SPEC_VERSION          | Used to specify the version of the CycloneDX spec                   | 1.2, 1.3, 1.4                   | 1.4           |
| NPM_MC_TYPE               | Used to specify the type of main component                          | application, firmware, library  | application   |
| NPM_OMIT                  | Used to omit specific dependency types                              | dev, optional, peer             | none          | 
| NPM_OUTPUT_FORMAT         | Used to specify output format of the sBOM                           | json, xml                       | json          |
| NPM_PACKAGE_LOCK_ONLY     | Used to use only the package-lock.json file to find dependencies    | true, false                     | false         |
| SCAN_SBOM_WITH_BOMBER     | Used to scan the sBOM for vulnerabilities using bomber              | true, false                     | false         |
| BOMBER_DEBUG              | Used to enable debug mode during bomber scan                        | true, false                     | false         |
| BOMBER_IGNORE_FILE        | Used to tell bomber what CVEs to ignore                             | <path to bomber ignore file>    | none          |
| BOMBER_PROVIDER           | Used to specify what vulnerability provider bomber will use         | osv, ossindex                   | osv           |
| BOMBER_PROVIDER_TOKEN     | Used to specify an API token for the selected provider              | <provider apitoken>             | none          |
| BOMBER_PROVIDER_USERNAME  | Used to specify an username for the selected provider               | <provider username>             | none          |
| BOMBER_OUTPUT_FORMAT      | Used to specify the output format of the bomber scan                | json, html, stdout              | stdout        |

## Details

Generates a CycloneDX compliant Software Bill of Materials
for a node/npm project. The generated sBOM will be created in the
sbom-output directory and be named `${BITBUCKET_REPO_SLUG}-sbom.json`

## Prerequisites

npm dependencies must be installed first. It is advised to install npm dependencies
in one step then archive them, so they can be read by the pipe. See the example below.

## Example

A working pipeline for the popular [auditjs](https://www.npmjs.com/package/auditjs) 
tool has been created as an example. The pipeline in
this fork of the [auditjs](https://www.npmjs.com/package/auditjs) tool will install the required
dependencies then generate a CycloneDX sBOM containing all the ingredients which make up the 
product.

* [Repository Link](https://bitbucket.org/ccideas1/fork-auditjs/src/main/)
* [Link to bitbucket-pipelines.yml](https://bitbucket.org/ccideas1/fork-auditjs/src/main/bitbucket-pipelines.yml)
* [Link to pipeline](https://bitbucket.org/ccideas1/fork-auditjs/pipelines/results/4)

## Support

If you'd like help with this pipe, or you have an issue, or a feature request, [let us know](https://github.com/ccideas/cyclonedx-npm-pipe/issues).

If you are reporting an issue, please include:

the version of the pipe
relevant logs and error messages
steps to reproduce

## Credits

This Bitbucket pipe is a collection and integration of the following open source tools

* [cyclonedx-npm](https://github.com/CycloneDX/cyclonedx-node-npm)
* [bomber](https://github.com/devops-kung-fu/bomber)

A big thank-you to the teams and volunteers who make these amazing tools available
