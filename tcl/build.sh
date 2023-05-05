#!/bin/sh

set -e

. "$(dirname "$0")/../lib/utils.sh"

# Version of Tcl to fetch. Will be converted to a git tag.
VERSION=${VERSION:-"8.0.5"}

# Souce and destination directories. Will default to a subdirectory of the
# current, carrying the version number when empty.
DESTINATION=${DESTINATION:-""}
SOURCE=${SOURCE:-""}

# Architecture to build for. Will default to the current one.
ARCHITECTURE=${ARCHITECTURE:-"$(uname -s | tolower)-$(uname -m | tolower)"}

# Shared or static libraries?
SHARED=${SHARED:-"1"}

# shellcheck disable=SC2034 # Variable used in lib/options.sh
USAGE="builds Tcl using Docker"
. "$(dirname "$0")/../lib/options.sh"

[ -z "$SOURCE" ] && SOURCE="${ROOTDIR%/}/tcl${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="${ROOTDIR%/}/${ARCHITECTURE}/tcl${VERSION}"

mkdir -p "$DESTINATION"

docker image build -f "$(dirname "$0")/Dockerfile" \
  --build-arg "VERSION=${VERSION}" \
  --build-arg "SOURCE=${SOURCE}" \
  --build-arg "DESTINATION=${DESTINATION}" \
  -t "tcl${VERSION}-${ARCHITECTURE}" \
  "$(dirname "$0")/.."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "${DESTINATION}:/dist" \
  -v "${SOURCE}:/src" \
  -w /src \
  "tcl${VERSION}-${ARCHITECTURE}" \
    --source "/src" \
    --destination /dist \
    --arch "$ARCHITECTURE" \
    --shared="$SHARED"
