#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../lib/utils.sh"

# DINO_GITHUB_TAG is the tag to fetch from GitHub. It will be converted to a git tag
# and the repo will be downloaded at that tag.
DINO_GITHUB_TAG=${DINO_GITHUB_TAG:-"main"}

# DINO_GITHUB_PRJ is the fully-qualified name of the repository to fetch from GitHub,
# e.g. efrecon/dinosaurs.
DINO_GITHUB_PRJ=${DINO_GITHUB_PRJ:-}

# By default that name of the tar file will be the name of the internal project
DINO_GITHUB_NAME=${DINO_GITHUB_NAME:-"$DINO_PROJECT"}

# URL root for GitHub
DINO_GITHUB_ROOT=${DINO_GITHUB_ROOT:-"https://github.com/"}

# Set the usage message
USAGE="Download a project from GitHub and extract it into the destination directory"

while [ $# -gt 0 ]; do
  case "$1" in
    -p | --project) # The basename to use, empty for project's name
      DINO_GITHUB_PRJ=$2; shift 2;
      ;;
    --project=*)
      DINO_GITHUB_PRJ="${1#*=}"; shift 1;
      ;;

    -t | --tag) # The git tag to download the tarball at.
      DINO_GITHUB_TAG=$2; shift 2;
      ;;
    --tag=*)
      DINO_GITHUB_TAG="${1#*=}"; shift 1;
      ;;

    -n | --name) # The name of the tar file.
      DINO_GITHUB_NAME=$2; shift 2;
      ;;
    --name=*)
      DINO_GITHUB_NAME="${1#*=}"; shift 1;
      ;;

    -h | --help) # Show the help
      usage;;

    --) shift; break;;

    -*) usage 1;;

    *) break;;
  esac
done

[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_GITHUB_PRJ:-}" ] && printf "You must give GitHub project name!" && exit 1

# This is the GitHub URL to fetch the tarball from.
GITHUB_URL="${DINO_GITHUB_ROOT%/}/${DINO_GITHUB_PRJ}/archive/refs/tags/${DINO_GITHUB_TAG}.tar.gz"

# Download the tarball to a temporary directory and extract it to another
# temporary directory.
dwdir=$(mktemp -d)
download "$GITHUB_URL" "$dwdir/${DINO_GITHUB_NAME}.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/${DINO_GITHUB_NAME}.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DINO_DEST"
verbose "Extracting GitHub snapshot to $DINO_DEST"
tar -C "${tardir}/${DINO_GITHUB_NAME}-${DINO_GITHUB_TAG}" -cf - . | tar -C "$DINO_DEST" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
