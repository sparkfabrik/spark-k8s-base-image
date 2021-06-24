FROM gcr.io/google.com/cloudsdktool/cloud-sdk:346.0.0-alpine

LABEL org.opencontainers.image.source https://github.com/sparkfabrik/spark-k8s-deployer

# https://github.com/docker/compose/releases
ENV COMPOSE_VERSION 1.29.2
# https://download.docker.com/linux/static/stable/x86_64
ENV DOCKER_VERSION 20.10.7
ENV DOCKER_BUILDX_VERSION v0.5.1
ENV HELM3_VERSION 3.3.1
ENV AWS_CLI_VERSION 1.16.305

RUN apk add --no-cache py-pip python3-dev curl make gettext bash openssl libffi-dev openssl-dev gcc libc-dev make jq rust cargo bat && \
    # Install docker and docker-compose.
    curl -fSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/local/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && docker -v \
    && pip install "docker-compose==${COMPOSE_VERSION}" \
    && docker-compose --version \
    && mkdir -p ~/.docker/cli-plugins \
    && curl -fSL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64" -o ~/.docker/cli-plugins/docker-buildx \
    && chmod +x ~/.docker/cli-plugins/docker-buildx \
    && gcloud components install kubectl --quiet \
    && kubectl version --client \
    # Install Helm 3:
    && wget -O helm-v${HELM3_VERSION}-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM3_VERSION}-linux-amd64.tar.gz \
    && tar -xzf helm-v${HELM3_VERSION}-linux-amd64.tar.gz \
    && cp linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm helm-v${HELM3_VERSION}-linux-amd64.tar.gz \
    && rm -fr linux-amd64/ \
    && helm version -c \
    # Add a symlink for helm3 command for legacy reasons.
    && ln -s /usr/local/bin/helm /usr/local/bin/helm3

RUN pip install awscli==${AWS_CLI_VERSION}

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ADD scripts /scripts
RUN chmod -R +rwx scripts
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]
