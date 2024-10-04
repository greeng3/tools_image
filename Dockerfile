FROM greeng340or/python-dev:latest

LABEL maintainer="greeng3@obscure-reference.com"

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    nodejs \
    npm

## Go as a prerequisite
# Install Go
RUN add-apt-repository -y ppa:longsleep/golang-backports && \
    apt-get update && \
    apt-get install -y golang-go

# Set Go environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Create Go workspace directories
RUN mkdir -p /go/src /go/bin /go/pkg

## Rust as a prerequisite
RUN apt install -y \
    pkg-config \
    libssl-dev

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Actual tools
## C/C++
RUN apt-get install -y \
    clang-format \
    clang-tidy

# Docker
RUN go install github.com/jessfraz/dockfmt@latest

# hadolint
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

# dockerfilelint
RUN npm install -g dockerfilelint

## go
# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.54.2

# Install delve
RUN go install github.com/go-delve/delve/cmd/dlv@latest

## JSON
COPY json_format.py /usr/local/bin/
RUN chmod -R o+x /usr/local/bin/json_format.py

## Rust


## Shell
RUN apt-get install -y \
    shellcheck \
    shfmt

## Rust
RUN rustup component add rustfmt clippy

# TOML
RUN case "$(dpkg --print-architecture)" in \
    'amd64') \
        URL=https://github.com/tamasfe/taplo/releases/download/0.9.3/taplo-full-linux-x86_64.gz; \
    ;; \
    'arm64') \
        URL=https://github.com/tamasfe/taplo/releases/download/0.9.3/taplo-full-linux-aarch64.gz; \
    ;; \
    *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac && \
    curl -fsSL $URL -o taplo.gz && \
    gunzip -c taplo.gz > /usr/local/bin/taplo && \
    chmod -R o+x /usr/local/bin/taplo && \
    rm -rf taplo.gz

# XML
RUN apt-get install -y \
    libxml2-utils

# YAML
RUN apt-get install -y \
    yamllint

# Install prettier - lots of things (including YAML)
RUN npm install -g prettier

COPY file_lists.py /usr/local/bin/
RUN chmod -R o+x /usr/local/bin/file_lists.py

# put container poetry packages in the spot where workspace poetry packages will land
RUN mkdir -p /workspace
WORKDIR /workspace
COPY poetry.lock pyproject.toml /workspace/
RUN poetry install

# Not really sure what's a better place for Makefile to land.
COPY Makefile /
WORKDIR /

RUN apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
    apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
