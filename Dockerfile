FROM node:18-bullseye-slim

ARG ARCH

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV CYCLONEDX_NPM_VERSION="1.16.1" \
    GEN_SBOM_SCRIPT_LOCATION="/opt"
ENV PATH="${GEN_SBOM_SCRIPT_LOCATION}:${PATH}"

COPY gen_*.sh $GEN_SBOM_SCRIPT_LOCATION/

# install dependencies
RUN npm install --global @cyclonedx/cyclonedx-npm@${CYCLONEDX_NPM_VERSION} \
  && rm -rf /root/.npm

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["gen_sbom.sh"]
