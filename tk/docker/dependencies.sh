#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/utils.sh
. "$(dirname "$0")/../share/dinosaurs/utils.sh"

# Turn down warnings about non-interactive mode
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

repoint_sources_list
if_sudo apt-get update
if_sudo apt-get install -y \
    build-essential autoconf gcc-multilib libc6-dev-i386 libtool libX11-dev; # libxss-dev libxft-dev libxext-dev libxmu-dev libxpm-dev libxinerama-dev libxrandr-dev libxt-dev libxv-dev libx11-xcb-dev libxcb1-dev libxkb-dev libxrender-dev libxss-dev libxv-dev libxkbcommon-dev libxkbfile
