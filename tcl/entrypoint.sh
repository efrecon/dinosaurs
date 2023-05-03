#!/bin/sh

set -e


tolower() { tr '[:upper:]' '[:lower:]'; }
# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-"/usr/local"}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(uname -s | tolower)-$(uname -m | tolower)"}

# This uses the comments behind the options to show the help. Not extremly
# correct, but effective and simple.
# shellcheck disable=SC2120
usage() {
  echo "$0 builds Tcl for different architectures" && \
    grep -E "[[:space:]]+-.+)[[:space:]]+#" "$0" |
    sed 's/#//' |
    sed -r 's/([a-z])\)/\1/'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -d | --dest | --destination) # The destination directory.
      DESTINATION=$2; shift 2;;
    --dest=* | --destination=*)
      DESTINATION="${1#*=}"; shift 1;;

    -a | --arch | --architecture) # The architecture to build for.
      ARCHITECTURE=$2; shift 2;;
    --arch=* | --architecture=*)
      ARCHITECTURE="${1#*=}"; shift 1;;

    -h | --help) # Show the help.
      usage;;

    --) shift; break;;

    -*) echo "Unknown option: $1" >&2; exit 1;;

    *) break;;
  esac
done

cd unix
autoconf
case "$ARCHITECTURE" in
  linux-x86_64)
    CFLAGS="-m64" ./configure --enable-gcc --prefix="$DESTINATION"
    ;;
  linux-i?86)
    CFLAGS="-m32" ./configure --enable-gcc --prefix="$DESTINATION"
    ;;
  *)
    echo "Unsupported architecture: $ARCHITECTURE" >&2
    exit 1
    ;;
esac
make
make install-binaries install-libraries; # avoid manuals because they require hard links
make distclean
