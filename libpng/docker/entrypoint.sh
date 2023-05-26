#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/lib/utils.sh
. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-"/usr/local"}
SOURCE=${SOURCE:-"/usr/local/src"}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# Shared or static libraries?
SHARED=${SHARED:-"1"}

# Compilation steps to run.
STEPS=${STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="builds libpng on UNIX"

# shellcheck source=../../share/dinosaurs/lib/options.sh
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

cd "${SOURCE}"

if printf '%s\n' "$STEPS" | grep -q configure; then
  verbose "Configuring libpng"
  case "$ARCHITECTURE" in
    linux-x86_64)
      CFLAGS="-m64" prefix="$DESTINATION" ./configure "$@"
      ;;
    linux-i?86)
      CFLAGS="-m32" prefix="$DESTINATION" ./configure "$@"
      ;;
    *)
      echo "Unsupported architecture: $ARCHITECTURE" >&2
      exit 1
      ;;
  esac
fi
if printf '%s\n' "$STEPS" | grep -q build; then
  verbose "Building libpng"
  make
fi
if printf '%s\n' "$STEPS" | grep -q install; then
  verbose "Installing libpng"
  make install
fi
if printf '%s\n' "$STEPS" | grep -q clean; then
  verbose "Cleaning libpng"
  make distclean
fi
