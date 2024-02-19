DOCKER ?= docker
PWD ?= pwd
GEN_SBOM ?= ./gen_sbom.sh
NPM ?= npm
SAMPLE_JSON ?= sample.json

.PHONY: test
test:
	$(DOCKER) run --rm -it \
		-v $(PWD):/build \
		--workdir /build \
		bats/bats:1.9.0 test/**.bats --timing --show-output-of-passing-tests --verbose-run

.PHONY: shellcheck
shellcheck:
	$(DOCKER) run --rm -it \
		-v $(PWD):/build \
		--workdir /build \
		koalaman/shellcheck-alpine:v0.9.0 shellcheck -x ./*.sh ./**/*.bats

.PHONY: clean
clean:
	rm -rf sbom_output
	rm -rf output
	rm -rf build
	rm -rf node_modules
	rm package.json package-lock.json || echo "not found"

.PHONY: docker
docker:
	$(DOCKER) build --build-arg ARCH=arm64 --tag cyclonedx-bitbucket-npm-pipe:dev .

.PHONY: docker-amd64
docker-amd64:
	$(DOCKER) buildx build --platform linux/amd64 --build-arg ARCH=amd64 --tag cyclonedx-bitbucket-npm-pipe:dev .

.PHONY: docker-lint
docker-lint:
	$(DOCKER) run --rm -it \
		-v "$(shell pwd)":/build \
		--workdir /build \
		hadolint/hadolint:v2.12.0-alpine hadolint Dockerfile*

.PHONY: markdown-lint
markdown-lint:
	$(DOCKER) run --rm -it \
		-v "$(shell pwd)":/build \
		--workdir /build \
		markdownlint/markdownlint:0.13.0 *.md

.PHONY: scan-project
scan-project:
	export NPM_PACKAGE_LOCK_ONLY=false && \
	export IGNORE_NPM_ERRORS=true && \
	export NPM_FLATTEN_COMPONENTS=false && \
	export NPM_SHORT_PURLS=false && \
	export NPM_OUTPUT_REPRODUCIBLE=false && \
	export NPM_SPEC_VERSION=1.4 && \
	export NPM_OUTPUT_FORMAT=json && \
	$(GEN_SBOM)

.PHONY: scan-project-docker
scan-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD):/tmp \
		--workdir /tmp \
		--env-file variables.list \
		cyclonedx-bitbucket-npm-pipe:dev

.PHONY: docker-debug
docker-debug:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp \
		--env-file variables.list \
		--entrypoint bash \
		cyclonedx-bitbucket-npm-pipe:dev

sample:
	@cp ${SAMPLE_JSON} package.json
	$(NPM) install
