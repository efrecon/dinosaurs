#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# This uses the comments behind the options to show the help. Not extremly
# correct, but effective and simple.
# shellcheck disable=SC2120
usage() {
  echo "$0 downloads Tcl into a directory" && \
    grep -E "[[:space:]]+-.+)[[:space:]]+#" "$0" |
    sed 's/#//' |
    sed -r 's/([a-z])\)/\1/'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -v | --version) # The version of Tcl to fetch.
      VERSION=$2; shift 2;;
    --version=*)
      VERSION="${1#*=}"; shift 1;;

    -d | --dest | --destination) # The destination directory.
      DESTINATION=$2; shift 2;;
    --dest=* | --destination=*)
      DESTINATION="${1#*=}"; shift 1;;

    -h | --help) # Show the help.
      usage;;

    --) shift; break;;

    -*) echo "Unknown option: $1" >&2; exit 1;;

    *) break;;
  esac
done

[ -z "$DESTINATION" ] && DESTINATION="$(pwd)/tcl${VERSION}"
GIT_TAG="core-$(printf %s\\n "$VERSION" | tr . -)"
TCL_URL="https://github.com/tcltk/tcl/archive/refs/tags/${GIT_TAG}.tar.gz"

# Download the tarball and extract it to another temporary directory.
dwdir=$(mktemp -d)
download "$TCL_URL" "$dwdir/tcl.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/tcl.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DESTINATION"
tar -C "${tardir}/tcl-${GIT_TAG}" -cf - . | tar -C "$DESTINATION" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
