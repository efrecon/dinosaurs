#!/bin/sh

set -eu

. "$(dirname "$0")/../share/dinosaurs/lib/utils.sh"
USAGE="Clean binaries and downloads for project(s)"
. "$(dirname "$0")/../share/dinosaurs/lib/options.sh"

clean() {
  verbose "Cleaning $proj"
  find "$OUTDIR" -maxdepth 2 -depth -name "${1}*" -type d -exec rm -rf {} \;
}

if [ "$#" -eq 0 ]; then
  find "$ROOTDIR" -maxdepth 1 -type d -exec basename {} \; |
    grep -v -e '^\.' -e '^output$' -e '^share$' |
    while read -r proj; do
      clean "$proj"
    done
else
  for proj in "$@"; do
    clean "$proj"
  done
fi