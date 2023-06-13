FROM node:18.12.1-bullseye-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY *.sh /opt/

ENV GEN_SBOM_SCRIPT_LOCATION="/opt"
ENV PATH="${GEN_SBOM_SCRIPT_LOCATION}:${PATH}"

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["gen_sbom.sh"]
