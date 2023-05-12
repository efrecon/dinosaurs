#!/bin/sh

set -eu

. "$(dirname "$0")/../share/dinosaurs/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/github.sh
GITHUB_PRJ="tcltk/tk"

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/options.sh
USAGE="downloads Tk into a directory"
. "$(dirname "$0")/../share/dinosaurs/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/$(dirname "$0")${VERSION}"
# shellcheck disable=SC2034 # Variable used in share/dinosaurs/github.sh
GITHUB_TAG="core_$(printf %s\\n "$VERSION" | tr . _)"

# Download at the git tag computed above from GitHub
. "$(dirname "$0")/../share/dinosaurs/github.sh"
