#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/lib/utils.sh
. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Turn down warnings about non-interactive mode
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

repoint_sources_list
if_sudo apt-get update
if_sudo apt-get install -y \
    build-essential autoconf gcc-multilib libc6-dev-i386 libtool libx11-dev
if_sudo apt-get install -y libx11-dev:i386 || true
