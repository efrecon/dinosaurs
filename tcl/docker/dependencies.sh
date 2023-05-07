#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/utils.sh
. "$(dirname "$0")/../share/dinosaurs/utils.sh"


SRC_LIST=$(mktemp)
sed s/archive/old-releases/g /etc/apt/sources.list > "$SRC_LIST"
if_sudo mv "$SRC_LIST" /etc/apt/sources.list
if_sudo apt-get update
DEBIAN_FRONTEND=noninteractive if_sudo apt-get upgrade -yy
DEBIAN_FRONTEND=noninteractive if_sudo apt-get install -y \
    build-essential autoconf gcc-multilib g++-multilib libc6-dev-i386 libtool
