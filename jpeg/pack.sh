#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"6b"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="Package libJPEG binaries into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Default source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${OUTDIR%/}/${ARCHITECTURE}/${DINO_PROJECT}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${OUTDIR%/}/${ARCHITECTURE}"

# Package into a tarball
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tar.sh"
