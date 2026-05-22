FROM ghcr.io/actions/actions-runner

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    docker-buildx \
    groff \
    default-jre \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
 && unzip "/tmp/awscliv2.zip" \
 && ./aws/install \
 && rm -r "./aws" "/tmp/awscliv2.zip"

ENV ALLURE_REPO="https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline"
ENV ALLURE_VERSION="2.41.0"
RUN curl -fsSL "${ALLURE_REPO}/${ALLURE_VERSION}/allure-commandline-${ALLURE_VERSION}.tgz" -o "/tmp/allure.tgz" \
 && tar xzf /tmp/allure.tgz \
 && rm /tmp/allure.tgz \
 && rm -rf allure \
 && mv allure-${ALLURE_VERSION} allure

USER runner
