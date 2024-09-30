FROM greeng340or/python-dev:latest

LABEL maintainer="greeng3@obscure-reference.com"

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    clang-format \
    clang-tidy \
    libxml2-utils \
    nodejs \
    npm

#     shellcheck \
#     yamlfmt

# Install Go
RUN add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update && \
    apt-get install -y golang-go

# Set Go environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Create Go workspace directories
RUN mkdir -p /go/src /go/bin /go/pkg

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.54.2

# Install delve
RUN go install github.com/go-delve/delve/cmd/dlv@latest

# Install dockfmt
RUN go install github.com/jessfraz/dockfmt@latest

# Install hadoling
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
    ARCH_SUFFIX="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then \
    ARCH_SUFFIX="arm64"; \
    else \
    echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-$ARCH_SUFFIX && \
    chmod +x /usr/local/bin/hadolint

# Install dockerfilelint
RUN npm install -g dockerfilelint

# Install prettier
RUN npm install -g prettier
# prettier-plugin-docker - this may be a hallucination of ChatGPT, or have disappeared

COPY Makefile poetry.lock pyproject.toml file_lists.py /
WORKDIR /

RUN poetry install

RUN apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
    apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
