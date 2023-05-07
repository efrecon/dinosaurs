#!/bin/sh

set -eu

SRC_LIST=$(mktemp)
sed s/archive/old-releases/g /etc/apt/sources.list > "$SRC_LIST"
mv "$SRC_LIST" /etc/apt/sources.list
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential autoconf gcc-multilib g++-multilib libc6-dev-i386 libtool
