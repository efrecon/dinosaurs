#!/bin/sh

set -eu

. "$(dirname "$0")/../share/dinosaurs/utils.sh"

# Version of libjpeg to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"6b"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/options.sh
USAGE="downloads libJPEG into a directory"
. "$(dirname "$0")/../share/dinosaurs/options.sh"

# Internal project name, named after the directory this script is in
PROJECT=$(basename "$(dirname "$0")")

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${PROJECT}${VERSION}"
# shellcheck disable=SC2034 # Variable used in share/dinosaurs/tarurl.sh
TARURL="http://ijg.org/files/jpegsrc.v${VERSION}.tar.gz"

# Download from the IJG website
. "$(dirname "$0")/../share/dinosaurs/tarurl.sh"
