#!/bin/sh

[ -z "${DESTINATION:-}" ] && printf "You must set DESTINATION variable!" && exit 1
[ -z "${SOURCE:-}" ] && printf "You must set SOURCE variable!" && exit 1
[ -z "${ARCHITECTURE:-}" ] && printf "You must set ARCHITECTURE variable!" && exit 1

# Basename for the name of the tarball to build when not default.
TAR_BASE=${TAR_BASE:-"$DINO_PROJECT"}

mkdir -p "$DESTINATION"
DESTFILE=${DESTINATION}/${TAR_BASE}${VERSION}-${ARCHITECTURE}.tar.gz

# Prints the name of the file on success.
if tar \
    -C "$(dirname "$SOURCE")" \
    -czf "$DESTFILE" \
    "$(basename "$SOURCE")"; then
  printf %s\\n "$DESTFILE"
fi