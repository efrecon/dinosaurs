#!/bin/sh

set -eu

. "$(cd "$(dirname "$0")"; pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of zlib to fetch.
DINO_VERSION=${DINO_VERSION:-"1.0.9"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads zlib into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_PROJECT}${DINO_VERSION}"
# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/tarurl.sh
TARURL="http://zlib.net/fossils/zlib-${DINO_VERSION}.tar.gz"

# Download from the zlib website
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/tarurl.sh"
