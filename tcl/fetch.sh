#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in lib/github.sh
GITHUB_PRJ="tcltk/tcl"

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="downloads Tcl into a directory"
. "$(dirname "$0")/../lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/tcl${VERSION}"
# shellcheck disable=SC2034 # Variable used in lib/github.sh
GITHUB_TAG="core-$(printf %s\\n "$VERSION" | tr . -)"

# Download at the git tag computed above from GitHub
. "$(dirname "$0")/../lib/github.sh"
