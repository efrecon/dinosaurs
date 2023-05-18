#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of zlib to fetch.
VERSION=${VERSION:-"1.0.9"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DESTINATION=${DESTINATION:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads zlib into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DESTINATION" ] && DESTINATION="${OUTDIR%/}/${DINO_PROJECT}${VERSION}"
# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/tarurl.sh
TARURL="http://zlib.net/fossils/zlib-${VERSION}.tar.gz"

# Download from the zlib website
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tarurl.sh"
