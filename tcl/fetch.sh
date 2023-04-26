#!/bin/sh

. "$(dirname "$0")/../lib/utils.sh"

TCL_VERSION=${TCL_VERSION:-"${1:-"8.0.5"}"}
GIT_TAG="core-$(printf %s\\n "$TCL_VERSION" | tr . -)"
TCL_URL="https://github.com/tcltk/tcl/archive/refs/tags/${GIT_TAG}.tar.gz"

DSTDIR="${DSTDIR:-"${2:-"$(pwd)/tcl${TCL_VERSION}"}"}"

# Download the tarball and extract it to another temporary directory.
dwdir=$(mktemp -d)
download "$TCL_URL" "$dwdir/tcl.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/tcl.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DSTDIR"
tar -C "${tardir}/tcl-${GIT_TAG}" -cf - . | tar -C "$DSTDIR" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"

