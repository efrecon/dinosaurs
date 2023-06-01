#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"8.0.5"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DINO_DEST=${DINO_DEST:-""}
DINO_SOURCE=${DINO_SOURCE:-""}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# Shared or static libraries?
DINO_SHARED=${DINO_SHARED:-"1"}

# Build using Docker when set to 1
DINO_DOCKER=${DINO_DOCKER:-"1"}

# Compilation steps to run.
DINO_STEPS=${DINO_STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="builds Tk using Docker"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

IMG_BASE=$DINO_PROJECT

# Set source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${IMG_BASE}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}/${IMG_BASE}${DINO_VERSION}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

# Look for Tcl, build it if not found
TCLSRC=${TCLSRC:-"$(dirname "$DINO_SOURCE")/tcl${DINO_VERSION}"}
if [ -d "$TCLSRC" ]; then
  verbose "Trying to use Tcl from $TCLSRC"
else
  warning "$TCLSRC is not a directory, will fetch it first"
  "$(dirname "$(readlink_f "$0")")/../tcl/fetch.sh" \
    --version "$DINO_VERSION" \
    --destination "$TCLSRC" \
    --verbose="$DINO_VERBOSE"
fi
TCLCLEAN=0
if [ -x "${TCLSRC}/unix/tclsh" ]; then
  verbose "Found tclsh at ${TCLSRC}/unix/tclsh"
else
  warning "${TCLSRC}/unix/tclsh is not executable, will build Tcl first"
  "$(dirname "$(readlink_f "$0")")/../tcl/build.sh" \
    --version "$DINO_VERSION" \
    --source "$TCLSRC" \
    --arch "$DINO_ARCH" \
    --shared="$DINO_SHARED" \
    --docker="$DINO_DOCKER" \
    --steps "configure build" \
    --verbose="$DINO_VERBOSE"
  TCLCLEAN=1
fi

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/docker.sh
DEPENDENCIES="with-tcl=${TCLSRC}:${TCLSRC}/unix"
if [ "$DINO_DOCKER" = "1" ]; then
  verbose "Building in Docker container (tcl at $TCLSRC) and installing into $DINO_DEST"
  # Build using the Dockerfile from under the docker sub-directory
  . "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/docker.sh"
else
  . "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/host.sh"
fi

# If Tcl was built, clean it up
if [ "$TCLCLEAN" = "1" ]; then
  verbose "Cleaning auto-built Tcl"
  "$(dirname "$(readlink_f "$0")")/../tcl/build.sh" \
    --version "$DINO_VERSION" \
    --source "$TCLSRC" \
    --arch "$DINO_ARCH" \
    --shared="$DINO_SHARED" \
    --docker="$DINO_DOCKER" \
    --steps "clean"
fi