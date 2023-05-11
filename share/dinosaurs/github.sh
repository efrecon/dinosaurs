#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables.

[ -z "${DESTINATION:-}" ] && printf "You must set DESTINATION variable!" && exit 1

# GITHUB_TAG is the tag to fetch from GitHub. It will be converted to a git tag
# and the repo will be downloaded at that tag. You have to set this variable
# prior to inlining this script.
[ -z "${GITHUB_TAG:-}" ] && printf "You must set GITHUB_TAG variable!" && exit 1

# GITHUB_PRJ is the fully-qualified name of the repository to fetch from GitHub,
# e.g. efrecon/dinosaurs. You have to set this variable prior to inlining this
# script.
[ -z "${GITHUB_PRJ:-}" ] && printf "You must set GITHUB_PRJ variable!" && exit 1

# By default that name of the tar file will be the name of the internal project
GITHUB_NAME=${GITHUB_NAME:-"$(basename "$(dirname "$0")")"}

# This is the GitHub URL to fetch the tarball from.
GITHUB_URL="https://github.com/${GITHUB_PRJ}/archive/refs/tags/${GITHUB_TAG}.tar.gz"

# Download the tarball to a temporary directory and extract it to another
# temporary directory.
dwdir=$(mktemp -d)
download "$GITHUB_URL" "$dwdir/${GITHUB_NAME}.tar.gz"
tardir=$(mktemp -d)
mkdir -p "$tardir"
tar -xzf "$dwdir/${GITHUB_NAME}.tar.gz" -C "$tardir"

# Create the destination directory and copy the contents of the tarball to it.
mkdir -p "$DESTINATION"
verbose "Extracting GitHub snapshot to $DESTINATION"
tar -C "${tardir}/${GITHUB_NAME}-${GITHUB_TAG}" -cf - . | tar -C "$DESTINATION" -xf -

# Cleanup.
rm -rf "$dwdir" "$tardir"
