#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of libpng to build.
VERSION=${VERSION:-"1.0.69"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DESTINATION=${DESTINATION:-""}
SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# Build using Docker when set to 1
DOCKER=${DOCKER:-"1"}

# Compilation steps to run.
STEPS=${STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="builds libpng using Docker"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

IMG_BASE=$DINO_PROJECT

# Set source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${OUTDIR%/}/${IMG_BASE}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${OUTDIR%/}/${ARCHITECTURE}/${IMG_BASE}${VERSION}"

ZLIB_VERSION=${ZLIB_VERSION:-""}
# When no zlib version is speicified, try to guess it from the release that was
# made just before the modification date of the libpng source directory, a date
# that it automatically set by the fetch script to the date of the libpng
# release.
if [ -z "$ZLIB_VERSION" ]; then
  ZLIB_VERSION=$( curl -sSL https://www.zlib.net/fossils/ |
                  html2ascii|
                  grep 'zlib-' | while IFS= read -r line; do
                    # Extract just the date from the line (same as what we do in
                    # fetch.sh), convert it to a timestamp and compare to only
                    # keep the ones before.
                    dt=$(printf %s\\n "$line" | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}')
                    tstamp=$(date -d "$dt" +%s)
                    if [ "$tstamp" -lt "$(stat -c %Y "$SOURCE")" ]; then
                      printf %s\\n "$line"
                    fi
                  done |
                  tail -n 1 |
                  grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

  if [ -z "$ZLIB_VERSION" ]; then
    error "Could not guess zlib version, please set ZLIB_VERSION"
  else
    verbose "Guessed zlib version to be $ZLIB_VERSION"
  fi
fi


# Look for zlib, build it if not found
ZLIBSRC=${ZLIBSRC:-"$(dirname "$SOURCE")/zlib${ZLIB_VERSION}"}
if [ -d "$ZLIBSRC" ]; then
  verbose "Trying to use zlib from $ZLIBSRC"
else
  warning "$ZLIBSRC is not a directory, will fetch it first"
  "$(dirname "$(readlink_f "$0")")/../zlib/fetch.sh" \
    --version "$ZLIB_VERSION" \
    --destination "$ZLIBSRC" \
    --verbose="$DINO_VERBOSE"
fi
ZLIBCLEAN=0
if [ -x "${ZLIBSRC}/minigzip" ]; then
  verbose "Found minigzip at ${ZLIBSRC}/minigzip"
else
  warning "${ZLIBSRC}/minigzip is not executable, will build zlib first"
  "$(dirname "$(readlink_f "$0")")/../zlib/build.sh" \
    --version "$ZLIB_VERSION" \
    --source "$ZLIBSRC" \
    --arch "$ARCHITECTURE" \
    --docker="$DOCKER" \
    --steps "configure build install" \
    --verbose="$DINO_VERBOSE"
  ZLIBCLEAN=1
fi

PREFIX=${OUTDIR%/}/${ARCHITECTURE}/zlib${ZLIB_VERSION}
if [ "$DOCKER" = "1" ]; then
  verbose "Building in Docker container (zlib at $ZLIBSRC) and installing into $DESTINATION"
  # Build using the Dockerfile from under the docker sub-directory
  . "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/docker.sh"
else
  . "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/host.sh"
fi

# If zlib was built, clean it up
if [ "$ZLIBCLEAN" = "1" ]; then
  verbose "Cleaning auto-built zlib"
  "$(dirname "$(readlink_f "$0")")/../zlib/build.sh" \
    --version "$ZLIB_VERSION" \
    --source "$ZLIBSRC" \
    --arch "$ARCHITECTURE" \
    --docker="$DOCKER" \
    --steps "clean"
fi