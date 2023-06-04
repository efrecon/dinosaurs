#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"6b"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DINO_DEST=${DINO_DEST:-""}
DINO_SOURCE=${DINO_SOURCE:-""}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# Build using Docker when set to 1
DINO_DOCKER=${DINO_DOCKER:-"1"}

# Compilation steps to run.
DINO_STEPS=${DINO_STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="builds libjpeg"
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/options.sh"

# Set source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${DINO_PROJECT}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}/${DINO_PROJECT}${DINO_VERSION}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

# Export all DINO_* variables
for var in $(set | grep '^DINO_'|sed 's/=.*//g'); do export "${var?}"; done

if [ "$DINO_DOCKER" = "1" ]; then
  verbose "Building in Docker container and installing into $DINO_DEST"
  # Build using the Dockerfile from under the docker sub-directory
  "${DINO_ROOTDIR%/}/share/dinosaurs/bin/docker.sh" -- "$@"
else
  verbose "Building directly in host (requires admin privileges) and installing into $DINO_DEST"
  "${DINO_ROOTDIR%/}/share/dinosaurs/bin/host.sh" -- "$@"
fi
