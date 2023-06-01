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
USAGE="builds Tk on UNIX"

# shellcheck source=../../share/dinosaurs/lib/options.sh
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

cd "${DINO_SOURCE}/unix"

if printf '%s\n' "$DINO_STEPS" | grep -q configure; then
  verbose "Configuring Tk"
  autoconf
  case "$DINO_ARCH" in
    x86_64-*-linux*)
      CFLAGS="-m64" ./configure --enable-gcc --enable-shared="$DINO_SHARED" --prefix="$DINO_DEST" "$@"
      ;;
    i?86-*-linux*)
      CFLAGS="-m32" LDFLAGS="-m32" ./configure --enable-gcc --enable-shared="$DINO_SHARED" --prefix="$DINO_DEST" "$@"
      ;;
    *)
      echo "Unsupported architecture: $DINO_ARCH" >&2
      exit 1
      ;;
  esac
fi
if printf '%s\n' "$DINO_STEPS" | grep -q build; then
  verbose "Building Tk"
  make
fi
if printf '%s\n' "$DINO_STEPS" | grep -q install; then
  verbose "Installing Tk"
  if [ -f "install-sh" ]; then
    if ! [ -x "install-sh" ]; then
      warning "Fixing install-sh permissions"
      chmod a+x "install-sh"
    fi
  fi
  # avoid manuals because they require hard links
  make install-binaries install-libraries
fi
if printf '%s\n' "$DINO_STEPS" | grep -q clean; then
  verbose "Cleaning Tk"
  make distclean
fi
