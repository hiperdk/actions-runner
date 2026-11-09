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
    openssh-client \
 && rm -rf /var/lib/apt/lists/*

RUN . /etc/build-arch \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "/tmp/awscliv2.zip" \
 && unzip "/tmp/awscliv2.zip" \
 && ./aws/install \
 && rm -r "./aws" "/tmp/awscliv2.zip"

ARG DOCKER_COMPOSE_VERSION="v5.7.0"
RUN . /etc/build-arch \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o /usr/local/lib/docker/cli-plugins/docker-compose \
 && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

ARG DOCKER_BUILDX_VERSION="v0.38.2"
RUN . /etc/build-arch \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -fsSL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-${TARGETARCH}" -o /usr/local/lib/docker/cli-plugins/docker-buildx \
 && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

RUN mkdir /home/runner/.ssh \
 && chown runner:runner /home/runner/.ssh \
 && mkdir -p /home/runner/.docker/buildx/instances \
 && chown -R runner:runner /home/runner/.docker
COPY --chown=runner:runner builder_known_hosts /home/runner/.ssh/known_hosts
COPY --chown=runner:runner buildx_instance_config.json /home/runner/.docker/buildx/instances/release-amazon

USER runner
