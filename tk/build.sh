#!/bin/sh

set -eu

. "$(dirname "$0")/../share/dinosaurs/utils.sh"

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

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/options.sh
USAGE="builds Tk using Docker"
. "$(dirname "$0")/../share/dinosaurs/options.sh"

IMG_BASE=$(basename "$(dirname "$0")");

# Set source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${ROOTDIR%/}/${IMG_BASE}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${ARCHITECTURE}/${IMG_BASE}${VERSION}"

# Look for Tcl, build it if not found
TCLSRC=${TCLSRC:-"$(dirname "$SOURCE")/tcl${VERSION}"}
if [ -d "$TCLSRC" ]; then
  verbose "Trying to use Tcl from $TCLSRC"
else
  warning "$TCLSRC is not a directory, will fetch it first"
  "$(dirname "$0")/../tcl/fetch.sh" \
    --version "$VERSION" \
    --destination "$TCLSRC" \
    --verbose="$DINO_VERBOSE"
fi
TCLCLEAN=0
if [ -x "${TCLSRC}/unix/tclsh" ]; then
  verbose "Found tclsh at ${TCLSRC}/unix/tclsh"
else
  warning "${TCLSRC}/unix/tclsh is not executable, will build Tcl first"
  "$(dirname "$0")/../tcl/build.sh" \
    --version "$VERSION" \
    --source "$TCLSRC" \
    --arch "$ARCHITECTURE" \
    --shared="$SHARED" \
    --docker="$DOCKER" \
    --steps "configure build" \
    --verbose="$DINO_VERBOSE"
  TCLCLEAN=1
fi

if [ "$DOCKER" = "1" ]; then
  if [ "$(version "$VERSION")" -ge "$(version "8.4")" ]; then
    UBUNTU_VERSION=12.04
  fi
  # shellcheck disable=SC2034 # Variable used in share/dinosaurs/docker.sh
  DEPENDENCIES="with-tcl=${TCLSRC}:${TCLSRC}/unix"
  verbose "Building in Docker container (tcl at $TCLSRC) and installing into $DESTINATION"
  # Build using the Dockerfile from under the docker sub-directory
  . "$(dirname "$0")/../share/dinosaurs/docker.sh"
else
  verbose "Installing dependencies, requires admin privileges"
  "$(dirname "$0")/docker/dependencies.sh"

  verbose "Building and installing into $DESTINATION"
  mkdir -p "$DESTINATION"
  FLAGS=
  if [ "${SHARED:-}" = "0" ]; then
    FLAGS=--static
  elif [ "${SHARED:-}" = "1" ]; then
    FLAGS=--shared
  fi
  "$(dirname "$0")/docker/entrypoint.sh" \
    --source "$SOURCE" \
    --destination "$(readlink_f "$DESTINATION")" \
    --arch "$ARCHITECTURE" \
    --steps "${STEPS:-}" \
    --verbose="$DINO_VERBOSE" \
    $FLAGS \
    -- \
      --with-tcl="${TCLSRC}:${TCLSRC}/unix"
fi

# If Tcl was built, clean it up
if [ "$TCLCLEAN" ]; then
  verbose "Cleaning auto-built Tcl"
  "$(dirname "$0")/../tcl/build.sh" \
    --version "$VERSION" \
    --source "$TCLSRC" \
    --arch "$ARCHITECTURE" \
    --shared="$SHARED" \
    --docker="$DOCKER" \
    --steps "clean"
fi