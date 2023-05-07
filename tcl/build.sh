#!/bin/sh

set -eu

. "$(dirname "$0")/../share/dinosaurs/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DESTINATION=${DESTINATION:-""}
SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(architecture)"}

# Shared or static libraries?
SHARED=${SHARED:-"1"}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/options.sh
USAGE="builds Tcl using Docker"
. "$(dirname "$0")/../share/dinosaurs/options.sh"

IMG_BASE=$(basename "$(dirname "$0")");

# Set source and destination directories when empty, i.e. not set in options
[ -z "$SOURCE" ] && SOURCE="${ROOTDIR%/}/${IMG_BASE}${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${ARCHITECTURE}/${IMG_BASE}${VERSION}"

# Build using the Dockerfile from under the docker sub-directory
. "$(dirname "$0")/../share/dinosaurs/docker.sh"
