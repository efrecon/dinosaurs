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

mkdir -p "$DESTINATION"

docker image build -f "$(dirname "$0")/docker/Dockerfile" \
  --build-arg "VERSION=${VERSION}" \
  --build-arg "SOURCE=${SOURCE}" \
  --build-arg "DESTINATION=${DESTINATION}" \
  -t "$IMG_NAME" \
  "$(dirname "$0")/.."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "${DESTINATION}:/dist" \
  -v "${SOURCE}:/src" \
  -w /src \
  "$IMG_NAME" \
    --source "/src" \
    --destination /dist \
    --arch "$ARCHITECTURE" \
    --shared="$SHARED"
