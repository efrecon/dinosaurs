#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of libjpeg to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"6b"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="downloads libJPEG into a directory"
. "$(dirname "$0")/../lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/$(dirname "$0")${VERSION}"
# shellcheck disable=SC2034 # Variable used in lib/tarurl.sh
TARURL="http://ijg.org/files/jpegsrc.v${VERSION}.tar.gz"

# Download from the IJG website
. "$(dirname "$0")/../lib/tarurl.sh"
