#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../share/dinosaurs/lib/utils.sh"

# Version of libpng to fetch.
DINO_VERSION=${DINO_VERSION:-"1.0.69"}

# Destination directory. Will default to a subdirectory of the current, carrying
# the version number when empty.
DINO_DEST=${DINO_DEST:-""}

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/sourceforge.sh
SOURCEFORGE_PRJ="libpng"

# shellcheck disable=SC2034 # Variable used in share/dinosaurs/lib/options.sh
USAGE="downloads libpng into a directory"
. "$(dirname "$(readlink_f "$0")")/../share/dinosaurs/lib/options.sh"

# Set default destination directory when empty, i.e. not set in options
[ -z "$DINO_DEST" ] && DINO_DEST="${DINO_OUTDIR%/}/${DINO_PROJECT}${DINO_VERSION}"

SOURCEFORGE_NAME=${SOURCEFORGE_NAME:-"$DINO_PROJECT"}

__SF_TMPDIR=$(mktemp -d)

sourceforge_fetch() {
  download "$SOURCEFORGE_URL" "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz" || true
  if [ -f "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz" ]; then
    if command -v file >/dev/null 2>&1; then
      if file "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz" | grep -q "gzip"; then
        printf %s\\n "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz"
      else
        rm "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz"
      fi
    elif [ "$(stat -c %s "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz")" -gt 100000 ]; then
      printf %s\\n "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz"
    else
      rm "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz"
    fi
  fi
}

sourceforge_unpack() {
  mkdir -p "${__SF_TMPDIR}/$DINO_VERSION"
  tar -xzf "$__SF_TMPDIR/${SOURCEFORGE_NAME}.tar.gz" -C "${__SF_TMPDIR}/${DINO_VERSION}"

  # Create the destination directory and copy the contents of the tarball to it.
  mkdir -p "$DINO_DEST"
  verbose "Extracting sourceforge release tarball to $DINO_DEST"
  tar -C "${__SF_TMPDIR}/${DINO_VERSION}/${SOURCEFORGE_NAME}-${DINO_VERSION}" -cf - . | tar -C "$DINO_DEST" -xf -
}

sourceforge_download() {
  for subdir in "$@"; do
    SOURCEFORGE_URL="https://sourceforge.net/projects/${SOURCEFORGE_PRJ}/files/${subdir%/}/${SOURCEFORGE_NAME}-${DINO_VERSION}.tar.gz/download"
    sf_tgz=$(sourceforge_fetch)
    if [ -n "$sf_tgz" ]; then
      # Get the publication date of the release from the sourceforge page by
      # cleaning away all HTML, keeping only the lines not starting with spaces,
      # looking for the path the library at the proper version, outputing some
      # context after that line. Starting from there, we isolate something that
      # looks like a date, keep only the first one (just in case). This works
      # because the date appears after the name of the file in the HTML at SF.
      pubdate=$(download "https://sourceforge.net/projects/${SOURCEFORGE_PRJ}/files/${subdir%/}/" - |
                html2ascii |
                grep -vE '^[[:space:]]+'|
                grep -F "${SOURCEFORGE_NAME}-${DINO_VERSION}.tar.gz" -A 10 |
                grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' |
                head -n 1)
      sourceforge_unpack
      # If we had a date, set the modification date of the destination directory
      # to match that date. This is so we can use that date to look for a
      # matching zlib release.
      if [ -n "$pubdate" ]; then
        verbose "Setting modification date of $DINO_DEST to $pubdate"
        touch -d "$pubdate" "$DINO_DEST"
      fi
      break
    fi
  done
}

dver=$(version "$DINO_VERSION")
if [ "$dver" -ge "$(version "0.1")" ] && [ "$dver" -lt "$(version "1.0.0")" ]; then
  sourceforge_download "libpng00/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.0.0")" ] && [ "$dver" -lt "$(version "1.2.0")" ]; then
  sourceforge_download "libpng10/${DINO_VERSION}" "libpng10/older-releases/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.2.0")" ] && [ "$dver" -lt "$(version "1.4.0")" ]; then
  sourceforge_download "libpng12/${DINO_VERSION}" "libpng12/older-releases/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.4.0")" ] && [ "$dver" -lt "$(version "1.5.0")" ]; then
  sourceforge_download "libpng14/${DINO_VERSION}" "libpng14/older-releases/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.5.0")" ] && [ "$dver" -lt "$(version "1.6.0")" ]; then
  sourceforge_download "libpng15/${DINO_VERSION}" "libpng15/older-releases/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.6.0")" ] && [ "$dver" -lt "$(version "1.7.0")" ]; then
  sourceforge_download "libpng16/${DINO_VERSION}" "libpng16/older-releases/${DINO_VERSION}"
elif [ "$dver" -ge "$(version "1.7.0")" ]; then
  sourceforge_download "libpng17/${DINO_VERSION}" "libpng17/older-releases/${DINO_VERSION}"
fi
rm -rf "$__SF_TMPDIR"