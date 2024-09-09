FROM ubuntu:24.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-transport-https ca-certificates

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    python3-poetry \
    git \
    vim \
    curl \
    wget \
    clang-format \
    clang-tidy \
    libxml2-utils \
    nodejs \
    npm \
    pylint \
    python3-pylint-celery \
    python3-pylint-common \
    python3-pylint-flask \
    python3-pylint-plugin-utils \
    python3-coincidence \
    python3-pytest \
    python3-pytest-asyncio \
    python3-pytest-bdd \
    python3-pytest-click \
    python3-pytest-django \
    python3-pytest-djangoapp \
    python3-pytest-env \
    python3-pytest-flask \
    python3-pytest-httpserver \
    python3-pytest-instafail \
    python3-pytest-lazy-fixture \
    python3-pytest-localserver \
    python3-pytest-mock \
    python3-pytest-mpl \
    python3-pytest-multihost \
    python3-pytest-openfiles \
    python3-pytest-order \
    python3-pytest-pep8 \
    python3-pytest-pylint \
    python3-pytest-recording \
    python3-pytest-regressions \
    python3-pytest-runner \
    python3-pytest-services \
    python3-pytest-skip-markers \
    python3-pytest-sourceorder \
    python3-pytest-tempdir \
    python3-pytest-timeout \
    python3-pytest-toolbox \
    python3-pytest-xprocess

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

RUN poetry config virtualenvs.create false --local
RUN poetry lock
# RUN poetry install

RUN git config --global http.postBuffer 524288000 \
    && git clone --recurse-submodules https://github.com/google/pytype.git
WORKDIR /pytype
RUN pip install . --break-system-packages

WORKDIR /
RUN git clone https://github.com/cheshirekow/cmake_format.git

# RUN apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
#     apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

RUN mkdir /workspace
WORKDIR /workspace
