#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

ARCH=$(uname -s | tolower)-$(uname -m | tolower)
TCL_VERSION=${TCL_VERSION:-"${1:-"8.0.5"}"}
SRCDIR="${SRCDIR:-"${2:-"$(pwd)/tcl${TCL_VERSION}"}"}"
DSTDIR="${DSTDIR:-"${3:-"$(pwd)/${ARCH}/tcl${TCL_VERSION}"}"}"
mkdir -p "$DSTDIR"

docker image build -f "$(dirname "$0")/Dockerfile" \
  --build-arg "TCL_VERSION=${TCL_VERSION}" \
  --build-arg "SRCDIR=${SRCDIR}" \
  --build-arg "DSTDIR=${DSTDIR}" \
  -t "tcl${TCL_VERSION}-${ARCH}" \
  "$(dirname "$0")"
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "${DSTDIR}:/dist" \
  -v "${SRCDIR}:/src" \
  -w /src \
  "tcl${TCL_VERSION}-${ARCH}" \
    /dist