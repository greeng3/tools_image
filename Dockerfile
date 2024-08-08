FROM ubuntu:24.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-transport-https ca-certificates

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    software-properties-common \
    python3 \
    python3-pip \
    python3-poetry \
    git \
    vim \
    curl \
    wget

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    libxml2-utils \
    clang-format clang-tidy \
    shellcheck \
    yamlfmt 


COPY Makefile poetry.lock pyproject.toml /
WORKDIR /

RUN poetry config virtualenvs.create false --local
RUN poetry install

RUN apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
    apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /workspace
WORKDIR /workspace
