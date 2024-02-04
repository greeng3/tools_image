FROM ubuntu:23.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-transport-https ca-certificates && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    python3 python3-pip \
    apt upgrade && \
    apt-get purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}') && \
    apt-get autoremove -y; apt-get purge -y $(dpkg --list |grep '^rc' |awk '{print $2}') && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
