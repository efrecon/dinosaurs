#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
DINO_VERSION=${DINO_VERSION:-"8.0.5"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads Tk into a directory"
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_PROJECT}${DINO_VERSION}"

# Export all DINO_* variables
for var in $(set | grep '^DINO_'|sed 's/=.*//g'); do export "${var?}"; done

# Download at the git tag computed above from GitHub
"${DINO_ROOTDIR%/}/share/dinosaurs/bin/github.sh" \
  --project "tcltk/tk" \
  --tag "core_$(printf %s\\n "$DINO_VERSION" | tr . _)"
