#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../lib/utils.sh"

# The basename of the tarball locally.
DINO_TARURL_NAME=${DINO_TARURL_NAME:-"$DINO_PROJECT"}

# The URL to download the tarball from.
DINO_TARURL_URL=${DINO_TARURL_URL:-}

# Set the usage message
USAGE="Download URL in tar format and extract it into the destination directory"

while [ $# -gt 0 ]; do
  case "$1" in
    -u | --url) # The URL to download the tarball from.
      DINO_TARURL_URL=$2; shift 2;
      ;;
    --project=*)
      DINO_TARURL_URL="${1#*=}"; shift 1;
      ;;

    -n | --name) # The name of the tar file.
      DINO_TARURL_NAME=$2; shift 2;
      ;;
    --name=*)
      DINO_TARURL_NAME="${1#*=}"; shift 1;
      ;;

    -h | --help) # Show the help
      usage;;

    --) shift; break;;

    -*) usage 1;;

    *) break;;
  esac
done


[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_TARURL_URL:-}" ] && printf "You must give the URL to download from!" && exit 1

# Download the tarball to a temporary directory and extract it to another
# temporary directory.
dwdir=$(mktemp -d)
download "$DINO_TARURL_URL" "$dwdir/${DINO_TARURL_NAME}.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/${DINO_TARURL_NAME}.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DINO_DEST"
verbose "Extracting tarball to $DINO_DEST"
tar -C "${tardir}/${DINO_TARURL_NAME}-${DINO_VERSION}" -cf - . | tar -C "$DINO_DEST" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
