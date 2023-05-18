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
USAGE="builds Tcl on UNIX"

# shellcheck source=../../share/dinosaurs/lib/options.sh
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

cd "${SOURCE}/unix"

if printf '%s\n' "$STEPS" | grep -q configure; then
  verbose "Configuring Tcl"
  autoconf
  case "$ARCHITECTURE" in
    linux-x86_64)
      CFLAGS="-m64" ./configure --enable-gcc --enable-shared="$SHARED" --prefix="$DESTINATION" "$@"
      ;;
    linux-i?86)
      CFLAGS="-m32" LDFLAGS="-m32" ./configure --enable-gcc --enable-shared="$SHARED" --prefix="$DESTINATION" "$@"
      ;;
    *)
      echo "Unsupported architecture: $ARCHITECTURE" >&2
      exit 1
      ;;
  esac
fi
if printf '%s\n' "$STEPS" | grep -q build; then
  verbose "Building Tcl"
  make
fi
if printf '%s\n' "$STEPS" | grep -q install; then
  verbose "Installing Tcl"
  if [ -f "install-sh" ]; then
    if ! [ -x "install-sh" ]; then
      warning "Fixing install-sh permissions"
      chmod a+x "install-sh"
    fi
  fi
  # avoid manuals because they require hard links
  make install-binaries install-libraries
fi
if printf '%s\n' "$STEPS" | grep -q clean; then
  verbose "Cleaning Tcl"
  make distclean
fi
