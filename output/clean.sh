#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"
USAGE="Clean binaries and downloads for project(s)"
. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/options.sh"

clean() {
  verbose "Cleaning $proj"
  find "$DINO_OUTDIR" -maxdepth 2 -depth -name "${1}*" -exec rm -rf {} \;
}

if [ "$#" -eq 0 ]; then
  find "$DINO_ROOTDIR" -maxdepth 1 -type d -exec basename {} \; |
    grep -v -e '^\.' -e '^output$' -e '^share$' |
    while read -r proj; do
      clean "$proj"
    done
else
  for proj in "$@"; do
    clean "$proj"
  done
fi