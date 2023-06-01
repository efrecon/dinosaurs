#!/bin/sh

[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_SOURCE:-}" ] && printf "You must set DINO_SOURCE variable!" && exit 1
[ -z "${DINO_ARCH:-}" ] && printf "You must set DINO_ARCH variable!" && exit 1

# Basename for the name of the tarball to build when not default.
TAR_BASE=${TAR_BASE:-"$DINO_PROJECT"}

mkdir -p "$DINO_DEST"
DESTFILE=${DINO_DEST}/${TAR_BASE}${DINO_VERSION}-${DINO_ARCH}.tar.gz

# Prints the name of the file on success.
if tar \
    -C "$(dirname "$DINO_SOURCE")" \
    -czf "$DESTFILE" \
    "$(basename "$DINO_SOURCE")"; then
  printf %s\\n "$DESTFILE"
fi