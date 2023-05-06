#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables.

[ -z "${DESTINATION:-}" ] && printf "You must set DESTINATION variable!" && exit 1


[ -z "${TARURL:-}" ] && printf "You must set TARURL variable!" && exit 1

TARURL_NAME=${TARURL_NAME:-"$(basename "$(dirname "$0")")"}

# Download the tarball to a temporary directory and extract it to another
# temporary directory.
dwdir=$(mktemp -d)
download "$TARURL" "$dwdir/${TARURL_NAME}.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/${TARURL_NAME}.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DESTINATION"
tar -C "${tardir}/${TARURL_NAME}-${VERSION}" -cf - . | tar -C "$DESTINATION" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
