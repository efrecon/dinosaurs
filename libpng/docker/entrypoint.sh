#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/lib/utils.sh
. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-"/usr/local"}
DINO_SOURCE=${DINO_SOURCE:-"/usr/local/src"}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# Shared or static libraries?
DINO_SHARED=${DINO_SHARED:-"1"}

# Compilation steps to run.
DINO_STEPS=${DINO_STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="builds libpng on UNIX"

# shellcheck source=../../share/dinosaurs/lib/options.sh
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

cd "${DINO_SOURCE}"

if printf '%s\n' "$DINO_STEPS" | grep -q configure; then
  verbose "Configuring libpng"
  case "$DINO_ARCH" in
    x86_64-*-linux*)
      CFLAGS="-m64" prefix="$DINO_DEST" ./configure "$@"
      ;;
    i?86-*-linux*)
      CFLAGS="-m32" prefix="$DINO_DEST" ./configure "$@"
      ;;
    *)
      echo "Unsupported architecture: $DINO_ARCH" >&2
      exit 1
      ;;
  esac
fi
if printf '%s\n' "$DINO_STEPS" | grep -q build; then
  verbose "Building libpng"
  make
fi
if printf '%s\n' "$DINO_STEPS" | grep -q install; then
  verbose "Installing libpng"
  make install
fi
if printf '%s\n' "$DINO_STEPS" | grep -q clean; then
  verbose "Cleaning libpng"
  make distclean
fi
