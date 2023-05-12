#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/utils.sh
. "$(dirname "$0")/../share/dinosaurs/utils.sh"

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-"/usr/local"}
SOURCE=${SOURCE:-"/usr/local/src"}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(uname -s | tolower)-$(uname -m | tolower)"}

# Compilation steps to run.
STEPS=${STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/options.sh
USAGE="builds libJPEG on UNIX"

# shellcheck source=../../share/dinosaurs/options.sh
. "$(dirname "$0")/../share/dinosaurs/options.sh"

cd "${SOURCE}"

if printf '%s\n' "$STEPS" | grep -q configure; then
  verbose "Configuring ligJPEG"
  case "$ARCHITECTURE" in
    linux-x86_64)
      CFLAGS="-m64" ./configure --enable-gcc --prefix="$DESTINATION" "$@"
      ;;
    linux-i?86)
      CFLAGS="-m32" LDFLAGS="-m32" ./configure --enable-gcc --prefix="$DESTINATION" "$@"
      ;;
    *)
      echo "Unsupported architecture: $ARCHITECTURE" >&2
      exit 1
      ;;
  esac
fi

if printf '%s\n' "$STEPS" | grep -q build; then
  verbose "Building libJPEG"
  # Build
  make
fi

if printf '%s\n' "$STEPS" | grep -q install; then
  verbose "Installing libJPEG"
  # Create all destination directories and install, including libraries.
  mkdir -p "${DESTINATION}/bin" "${DESTINATION}/include" "${DESTINATION}/lib" "${DESTINATION}/man/man1"
  make install
  if grep -q '^install-lib:' Makefile; then
    make install-lib
  fi
fi

if printf '%s\n' "$STEPS" | grep -q clean; then
  verbose "Cleaning libJPEG"
  # Cleanup most of the source code
  make distclean
fi
