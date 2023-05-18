#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/lib/utils.sh
. "$(dirname "$0")/../share/dinosaurs/lib/utils.sh"

# Turn down warnings about non-interactive mode
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

repoint_sources_list
if_sudo apt-get update
if_sudo apt-get install -y \
    build-essential autoconf gcc-multilib libc6-dev-i386 libtool libX11-dev
if_sudo apt-get install -y libX11-dev:i386 || true
