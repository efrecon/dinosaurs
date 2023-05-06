#!/bin/sh

set -e

# shellcheck source=../../lib/utils.sh
. "$(dirname "$0")/../share/utils.sh"

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-"/usr/local"}
SOURCE=${SOURCE:-"/usr/local/src"}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(uname -s | tolower)-$(uname -m | tolower)"}

# Shared or static libraries?
SHARED=${SHARED:-"1"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="builds Tcl on UNIX"
# shellcheck source=../../lib/options.sh
. "$(dirname "$0")/../share/options.sh"

cd "${SOURCE}/unix"
autoconf
case "$ARCHITECTURE" in
  linux-x86_64)
    CFLAGS="-m64" ./configure --enable-gcc --enable-shared="$SHARED" --prefix="$DESTINATION"
    ;;
  linux-i?86)
    CFLAGS="-m32" LDFLAGS="-m32" ./configure --enable-gcc --enable-shared="$SHARED" --prefix="$DESTINATION"
    ;;
  *)
    echo "Unsupported architecture: $ARCHITECTURE" >&2
    exit 1
    ;;
esac
make
make install-binaries install-libraries; # avoid manuals because they require hard links
make distclean
