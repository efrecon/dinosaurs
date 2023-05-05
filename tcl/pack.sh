#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="Package Tcl binaries into a directory"
. "$(dirname "$0")/../lib/options.sh"

[ -z "$SOURCE" ] && SOURCE="${ROOTDIR%/}/${ARCHITECTURE}/tcl${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${ARCHITECTURE}"

mkdir -p "$DESTINATION"
DESTFILE=${DESTINATION}/tcl${VERSION}-${ARCHITECTURE}.tar.gz

# Prints the name of the file on success.
if tar \
    -C "$(dirname "$SOURCE")" \
    -czf "$DESTFILE" \
    "$(basename "$SOURCE")"; then
  printf %s\\n "$DESTFILE"
fi