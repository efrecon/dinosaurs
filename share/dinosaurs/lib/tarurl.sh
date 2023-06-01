#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables.

[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1


[ -z "${TARURL:-}" ] && printf "You must set TARURL variable!" && exit 1

TARURL_NAME=${TARURL_NAME:-"$DINO_PROJECT"}

# Download the tarball to a temporary directory and extract it to another
# temporary directory.
dwdir=$(mktemp -d)
download "$TARURL" "$dwdir/${TARURL_NAME}.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/${TARURL_NAME}.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DINO_DEST"
verbose "Extracting tarball to $DINO_DEST"
tar -C "${tardir}/${TARURL_NAME}-${DINO_VERSION}" -cf - . | tar -C "$DINO_DEST" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
