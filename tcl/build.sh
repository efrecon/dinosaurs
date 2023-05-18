#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DESTINATION=${DESTINATION:-""}
SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# Shared or static libraries?
SHARED=${SHARED:-"1"}

# Build using Docker when set to 1
DOCKER=${DOCKER:-"1"}

# Compilation steps to run.
STEPS=${STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="builds Tcl using Docker"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

IMG_BASE=$DINO_PROJECT

# Set source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${OUTDIR%/}/${IMG_BASE}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${OUTDIR%/}/${ARCHITECTURE}/${IMG_BASE}${VERSION}"

if [ "$DOCKER" = "1" ]; then
  if [ "$(version "$VERSION")" -ge "$(version "8.4")" ]; then
    UBUNTU_VERSION=12.04
  fi
  verbose "Building in Docker container and installing into $DESTINATION"
  # Build using the Dockerfile from under the docker sub-directory
  . "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/docker.sh"
else
  verbose "Installing dependencies, requires admin privileges"
  "$(dirname "$(readlink_f "$0")")/docker/dependencies.sh"

  verbose "Building and installing into $DESTINATION"
  mkdir -p "$DESTINATION"
  FLAGS=
  if [ "${SHARED:-}" = "0" ]; then
    FLAGS=--static
  elif [ "${SHARED:-}" = "1" ]; then
    FLAGS=--shared
  fi
  "$(dirname "$(readlink_f "$0")")/docker/entrypoint.sh" \
    --source "$SOURCE" \
    --destination "$(readlink_f "$DESTINATION")" \
    --arch "$ARCHITECTURE" \
    --steps "${STEPS:-}" \
    --verbose="$DINO_VERBOSE" \
    $FLAGS
fi
