#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of libpng to pack
DINO_VERSION=${DINO_VERSION:-"1.0.69"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

DINO_SOURCE=${DINO_SOURCE:-""}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="Package libpng binaries into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Default source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${DINO_ARCH}/${DINO_PROJECT}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

# Package into a tarball
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tar.sh"
