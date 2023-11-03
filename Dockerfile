FROM node:18.12.1-bullseye-slim

ARG ARCH

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get install --no-install-recommends -y curl=7.74.0-1.3+deb11u10 \
    && apt-get install --no-install-recommends -y ca-certificates=20210119 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ENV BOMBER_VERSION="0.4.5" \
    CYCLONEDX_NPM_VERSION="1.14.1" \
    GEN_SBOM_SCRIPT_LOCATION="/opt"
ENV PATH="${GEN_SBOM_SCRIPT_LOCATION}:${PATH}"

ARG BOMBER_URL="https://github.com/devops-kung-fu/bomber/releases/download/v${BOMBER_VERSION}/bomber_${BOMBER_VERSION}_linux_${ARCH}.deb"
ARG BOMBER_FILENAME="bomber_${BOMBER_VERSION}_linux_${ARCH}.deb"

COPY gen_*.sh $GEN_SBOM_SCRIPT_LOCATION/

# install dependencies
RUN npm install --global @cyclonedx/cyclonedx-npm@${CYCLONEDX_NPM_VERSION} \
  && curl -L -o $BOMBER_FILENAME $BOMBER_URL \
  && dpkg -i $BOMBER_FILENAME \
  && rm -rf /root/.npm

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["gen_sbom.sh"]
