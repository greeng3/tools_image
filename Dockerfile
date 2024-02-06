FROM ubuntu:23.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-transport-https ca-certificates && \
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    software-properties-common \
    python3 \
    python3-pip \
    python3-poetry \
    libxml2-utils \
    clang-format clang-tidy
#     shellcheck 
#     yamlfmt 

WORKDIR /opt/repo
RUN poetry config virtualenvs.create false --local && \
    poetry install && \
    apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
    apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /
