#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/github.sh
GITHUB_PRJ="tcltk/tcl"

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads Tcl into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_PROJECT}${DINO_VERSION}"
# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/github.sh
GITHUB_TAG="core-$(printf %s\\n "$DINO_VERSION" | tr . -)"

# Download at the git tag computed above from GitHub
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/github.sh"
