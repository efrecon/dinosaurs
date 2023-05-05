#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="downloads Tcl into a directory"
. "$(dirname "$0")/../lib/options.sh"

[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/tcl${VERSION}"
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
