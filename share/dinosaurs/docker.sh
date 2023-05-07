#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables.

[ -z "${DESTINATION:-}" ] && printf "You must set DESTINATION variable!" && exit 1
[ -z "${SOURCE:-}" ] && printf "You must set SOURCE variable!" && exit 1
[ -z "${ARCHITECTURE:-}" ] && printf "You must set ARCHITECTURE variable!" && exit 1
[ -z "${VERSION:-}" ] && printf "You must set VERSION variable!" && exit 1

# Basename for the name of the image to build when not default.
IMG_BASE=${IMG_BASE:-"$(basename "$(dirname "$0")")"}
# Fully qualified name of the image to build, by default uses a combination of
# the basename from above, the version and architecture.
IMG_NAME=${IMG_NAME:-"${IMG_BASE}${VERSION}-${ARCHITECTURE}"}

is_abspath() {
  case "$1" in
    /* | ~*) true;;
    *) false;;
  esac
}

# This is the same as readlink -f, which does not exist on MacOS
readlink_f() {
  if [ -d "$1" ]; then
    ( cd -P -- "$1" && pwd -P )
  elif [ -L "$1" ]; then
    if is_abspath "$(readlink "$1")"; then
      readlink_f "$(readlink "$1")"
    else
      readlink_f "$(dirname "$1")/$(readlink "$1")"
    fi
  else
    printf %s\\n "$(readlink_f "$(dirname "$1")")/$(basename "$1")"
  fi
}

mkdir -p "$DESTINATION"

docker image build -f "$(dirname "$0")/docker/Dockerfile" \
  --build-arg "VERSION=${VERSION}" \
  --build-arg "SOURCE=${SOURCE}" \
  --build-arg "DESTINATION=${DESTINATION}" \
  -t "$IMG_NAME" \
  "$(dirname "$0")/.."

FLAGS=
if [ "${SHARED:-}" = "0" ]; then
  FLAGS=--static
elif [ "${SHARED:-}" = "1" ]; then
  FLAGS=--shared
fi
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(readlink_f "${DESTINATION}"):/dist" \
  -v "$(readlink_f "${SOURCE}"):/src" \
  -w /src \
  "$IMG_NAME" \
    --source "/src" \
    --destination /dist \
    --arch "$ARCHITECTURE" \
    $FLAGS
