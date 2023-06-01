#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of libjpeg to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"6b"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads libJPEG into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${OUTDIR%/}/${DINO_PROJECT}${VERSION}"

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/tarurl.sh
TARURL="http://ijg.org/files/jpegsrc.v${VERSION}.tar.gz"
TARURL_NAME=jpeg

# Download from the IJG website
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tarurl.sh"
