FROM summerwind/actions-runner-dind:latest
ARG TARGETARCH
USER root

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) echo "ARCH=x86_64" >> /etc/build-arch ;; \
        arm64) echo "ARCH=aarch64" >> /etc/build-arch ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    groff \
    default-jre \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

RUN . /etc/build-arch \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "/tmp/awscliv2.zip" \
 && unzip "/tmp/awscliv2.zip" \
 && ./aws/install \
 && rm -r "./aws" "/tmp/awscliv2.zip"

ARG DOCKER_COMPOSE_VERSION="v5.1.4"
RUN . /etc/build-arch \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o /usr/libexec/docker/cli-plugins/docker-compose \
 && chmod +x /usr/libexec/docker/cli-plugins/docker-compose

ARG DOCKER_BUILDX_VERSION="v0.34.1"
RUN . /etc/build-arch \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -SL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o /usr/libexec/docker/cli-plugins/docker-buildx \
 && chmod +x /usr/libexec/docker/cli-plugins/docker-buildx

USER runner
