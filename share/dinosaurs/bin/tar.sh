#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../lib/utils.sh"

# Basename for the name of the tarball to build when not default.
DINO_TAR_BASE=${DINO_TAR_BASE:-"$DINO_PROJECT"}

DINO_TAR_DESTFILE=${DINO_TAR_DESTFILE:-""}

# Set the usage message
USAGE="Build tarball with the results of compilation"

while [ $# -gt 0 ]; do
  case "$1" in
    -b | --base) # The basename to use, empty for project's name
      DINO_TAR_BASE=$2; shift 2;
      ;;
    --base=*)
      DINO_TAR_BASE="${1#*=}"; shift 1;
      ;;

    -f | --file) # The full path to the name of the tarball
      DINO_TAR_BASE=$2; shift 2;
      ;;
    --file=*)
      DINO_TAR_BASE="${1#*=}"; shift 1;
      ;;

    -h | --help) # Show the help
      usage;;

    --) shift; break;;

    -*) usage 1;;

    *) break;;
  esac
done

# Good default for the destination file.
[ -z "$DINO_TAR_DESTFILE" ] && DINO_TAR_DESTFILE=${DINO_DEST}/${DINO_TAR_BASE}${DINO_VERSION}-${DINO_ARCH}.tar.gz

# Verify that the required variables are set.
[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_SOURCE:-}" ] && printf "You must set DINO_SOURCE variable!" && exit 1
[ -z "${DINO_ARCH:-}" ] && printf "You must set DINO_ARCH variable!" && exit 1

# Create the destination directory.
mkdir -p "$DINO_DEST"

# Create the tarball and print the name of the file on success.
if tar \
    -C "$(dirname "$DINO_SOURCE")" \
    -czf "$DINO_TAR_DESTFILE" \
    "$(basename "$DINO_SOURCE")"; then
  printf %s\\n "$DINO_TAR_DESTFILE"
fi