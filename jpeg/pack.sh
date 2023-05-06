#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"6b"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="Package libJPEG binaries into a directory"
. "$(dirname "$0")/../lib/options.sh"

# Internal project name, named after the directory this script is in
PROJECT=$(basename "$(dirname "$0")")

# Default source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${ROOTDIR%/}/${ARCHITECTURE}/${PROJECT}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${ARCHITECTURE}"

# Package into a tarball
. "$(dirname "$0")/../lib/tar.sh"
