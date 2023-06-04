#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"1.0.9"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

DINO_SOURCE=${DINO_SOURCE:-""}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="Package zlib binaries into a directory"
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/options.sh"

# Default source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${DINO_ARCH}/${DINO_PROJECT}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

# Export all DINO_* variables
for var in $(set | grep '^DINO_'|sed 's/=.*//g'); do export "${var?}"; done

# Package into a tarball
"${DINO_ROOTDIR%/}/share/dinosaurs/bin/tar.sh"
