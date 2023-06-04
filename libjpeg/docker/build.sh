#!/bin/sh

set -eu

# shellcheck source=../../share/dinosaurs/lib/utils.sh
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-"/usr/local"}
DINO_SOURCE=${DINO_SOURCE:-"/usr/local/src"}

# Architecture to build for. Will default to the current one.
DINO_ARCH=${DINO_ARCH:-"$(architecture)"}

# Compilation steps to run.
DINO_STEPS=${DINO_STEPS:-"configure build install clean"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="builds libJPEG on UNIX"

# shellcheck source=../../share/dinosaurs/lib/options.sh
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

cd "${DINO_SOURCE}"

if printf '%s\n' "$DINO_STEPS" | grep -q configure; then
  verbose "Configuring ligJPEG"
  case "$DINO_ARCH" in
    x86_64-*-linux*)
      CFLAGS="-m64" ./configure --enable-gcc --prefix="$DINO_DEST" "$@"
      ;;
    i?86-*-linux*)
      CFLAGS="-m32" LDFLAGS="-m32" ./configure --enable-gcc --prefix="$DINO_DEST" "$@"
      ;;
    *)
      echo "Unsupported architecture: $DINO_ARCH" >&2
      exit 1
      ;;
  esac
fi

if printf '%s\n' "$DINO_STEPS" | grep -q build; then
  verbose "Building libJPEG"
  # Build
  make
fi

if printf '%s\n' "$DINO_STEPS" | grep -q install; then
  verbose "Installing libJPEG"
  # Create all destination directories and install, including libraries.
  mkdir -p "${DINO_DEST}/bin" "${DINO_DEST}/include" "${DINO_DEST}/lib" "${DINO_DEST}/man/man1"
  make install
  if grep -q '^install-lib:' Makefile; then
    make install-lib
  fi
fi

if printf '%s\n' "$DINO_STEPS" | grep -q clean; then
  verbose "Cleaning libJPEG"
  # Cleanup most of the source code
  make distclean
fi
