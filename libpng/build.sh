#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of libpng to build.
DINO_VERSION=${DINO_VERSION:-"1.0.69"}

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
USAGE="builds libpng (and zlib at proper version)"
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/options.sh"

# Set source and destination directories when empty, i.e. not set in options
[ -z "$DINO_SOURCE" ] && DINO_SOURCE="${DINO_OUTDIR%/}/${DINO_IMG_BASE}${DINO_VERSION}"
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_ARCH}/${DINO_IMG_BASE}${DINO_VERSION}"

# Check that the source directory exists
[ ! -d "$DINO_SOURCE" ] && error "Source directory $DINO_SOURCE does not exist"

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
                    if [ "$tstamp" -lt "$(stat -c %Y "$DINO_SOURCE")" ]; then
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
ZLIBSRC=${ZLIBSRC:-"$(dirname "$DINO_SOURCE")/zlib${ZLIB_VERSION}"}
if [ -d "$ZLIBSRC" ]; then
  verbose "Trying to use zlib from $ZLIBSRC"
else
  warning "$ZLIBSRC is not a directory, will fetch it first"
  "${DINO_ROOTDIR%/}/zlib/fetch.sh" \
    --version "$ZLIB_VERSION" \
    --destination "$ZLIBSRC" \
    --verbose="$DINO_VERBOSE"
fi
ZLIBCLEAN=0
if [ -x "${ZLIBSRC}/minigzip" ]; then
  verbose "Found minigzip at ${ZLIBSRC}/minigzip"
else
  warning "${ZLIBSRC}/minigzip is not executable, will build zlib first"
  "${DINO_ROOTDIR%/}/zlib/build.sh" \
    --version "$ZLIB_VERSION" \
    --source "$ZLIBSRC" \
    --arch "$DINO_ARCH" \
    --docker="$DINO_DOCKER" \
    --steps "configure build install" \
    --verbose="$DINO_VERBOSE"
  ZLIBCLEAN=1
fi

# Export all DINO_* variables
for var in $(set | grep '^DINO_'|sed 's/=.*//g'); do export "${var?}"; done

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/docker.sh
if [ "$DINO_DOCKER" = "1" ]; then
  verbose "Building in Docker container (zlib at $ZLIBSRC) and installing into $DINO_DEST"
  # Build using the Dockerfile from under the docker sub-directory
  "${DINO_ROOTDIR%/}/share/dinosaurs/bin/docker.sh" \
    --prefix "${DINO_OUTDIR%/}/${DINO_ARCH}/zlib${ZLIB_VERSION}" \
    -- \
      "$@"
else
  verbose "Building directly in host (requires admin privileges) (zlib at $ZLIBSRC) and installing into $DINO_DEST"
  "${DINO_ROOTDIR%/}/share/dinosaurs/bin/host.sh" \
    --prefix "${DINO_OUTDIR%/}/${DINO_ARCH}/zlib${ZLIB_VERSION}" \
    -- \
      "$@"
fi

# If zlib was built, clean it up
if [ "$ZLIBCLEAN" = "1" ]; then
  verbose "Cleaning auto-built zlib"
  "${DINO_ROOTDIR%/}/zlib/build.sh" \
    --version "$ZLIB_VERSION" \
    --source "$ZLIBSRC" \
    --arch "$DINO_ARCH" \
    --docker="$DINO_DOCKER" \
    --steps "clean"
fi