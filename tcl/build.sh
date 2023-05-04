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

# This uses the comments behind the options to show the help. Not extremly
# correct, but effective and simple.
# shellcheck disable=SC2120
usage() {
  echo "$0 builds Tcl using Docker" && \
    grep -E "[[:space:]]+-.+)[[:space:]]+#" "$0" |
    sed 's/#//' |
    sed -r 's/([a-z])\)/\1/'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -v | --version) # The version of Tcl to build (also used for specifying the default directories)
      VERSION=$2; shift 2;;
    --version=*)
      VERSION="${1#*=}"; shift 1;;

    -d | --dest | --destination) # The destination directory.
      DESTINATION=$2; shift 2;;
    --dest=* | --destination=*)
      DESTINATION="${1#*=}"; shift 1;;

    -s | --src | --source) # The source directory.
      SOURCE=$2; shift 2;;
    --src=* | --source=*)
      SOURCE="${1#*=}"; shift 1;;

    --shared)   # Force building of shared libraries if possible
      SHARED=1; shift 1;;
    --shared=*)
      SHARED="${1#*=}"; shift 1;;

    --static)   # Force building of static libraries if possible
      SHARED=0; shift 1;;

    -a | --arch | --architecture) # The architecture to build for.
      ARCHITECTURE=$2; shift 2;;
    --arch=* | --architecture=*)
      ARCHITECTURE="${1#*=}"; shift 1;;

    -h | --help) # Show the help.
      usage;;

    --) shift; break;;

    -*) echo "Unknown option: $1" >&2; exit 1;;

    *) break;;
  esac
done

[ -z "$SOURCE" ] && SOURCE="$(pwd)/tcl${VERSION}"
[ -z "$DESTINATION" ] && DESTINATION="$(pwd)/${ARCHITECTURE}/tcl${VERSION}"

mkdir -p "$DESTINATION"

docker image build -f "$(dirname "$0")/Dockerfile" \
  --build-arg "VERSION=${VERSION}" \
  --build-arg "SOURCE=${SOURCE}" \
  --build-arg "DESTINATION=${DESTINATION}" \
  -t "tcl${VERSION}-${ARCHITECTURE}" \
  "$(dirname "$0")"
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
