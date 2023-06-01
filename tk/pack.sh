#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

DINO_SOURCE=${DINO_SOURCE:-""}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="Package Tcl binaries into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Default source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${DINO_ARCH}/${DINO_PROJECT}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

# Package into a tarball
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tar.sh"
