FROM ghcr.io/actions/actions-runner
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

ARG DOCKER_COMPOSE_VERSION="v5.1.2"
RUN . /etc/build-arch \
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o /usr/local/lib/docker/cli-plugins/docker-compose \
 && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

RUN . /etc/build-arch \
 && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "/tmp/awscliv2.zip" \
 && unzip "/tmp/awscliv2.zip" \
 && ./aws/install \
 && rm -r "./aws" "/tmp/awscliv2.zip"

ENV ALLURE_REPO="https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline"
ENV ALLURE_VERSION="2.41.0"
RUN curl -fsSL "${ALLURE_REPO}/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.tgz" -o "/tmp/allure.tgz" \
 && tar xzf /tmp/allure.tgz \
 && rm /tmp/allure.tgz \
 && mv allure-${ALLURE_VERSION} /allure

USER runner
