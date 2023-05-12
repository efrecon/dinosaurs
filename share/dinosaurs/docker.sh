#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables. NOTE: It DESTROYS the program's argument
# vector to be able to operate.

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

# Use the programs main argument vector to build arguments that will be passed
# to docker run. First, start with the arguments to docker run itself
set -- \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(readlink_f "${DESTINATION}"):/usr/local" \
  -v "$(readlink_f "${SOURCE}"):/src" \
  -w /src
# Dependencies should be written as name of option (without leading double
# dash), followed by an equal sign and the path to the dependency (no quotes).
# We remap them inside a directory that we can "own".
while IFS='=' read -r optname optpath; do
  # Arrange for Docker mount under namespaced directory if value was path to
  # file or directory.
  if [ -e "$optpath" ]; then
    optpath=$(readlink_f "${optpath}")
    set -- "$@" -v "${optpath}:/opt/dinosaurs/dependencies/${optpath#/}"
  fi
done <<EOF
$(printf %s\\n "${DEPENDENCIES:-}")
EOF

# Second: image name and arguments to the entry point
set -- "$@" \
  "$IMG_NAME" \
    --source "/src" \
    --destination /usr/local \
    --arch "$ARCHITECTURE"
if [ "${SHARED:-}" = "0" ]; then
  set -- "$@" --static
elif [ "${SHARED:-}" = "1" ]; then
  set -- "$@" --shared
fi
# Pick the dependencies again, use the same location as where they are remapped.
if [ -n "${DEPENDENCIES:-}" ]; then
  # Mark the end of the arguments to the entry point, all further options will
  # be passed to the build command.
  set -- "$@" --
fi
while IFS='=' read -r optname optpath; do
  # If value was path to file or directory, remap it to the namespaced directory
  # mounted above, otherwise pass it as-is.
  if [ -e "$optpath" ]; then
    optpath=$(readlink_f "${optpath}")
    set -- "$@" --"${optname}=/opt/dinosaurs/dependencies/${optpath#/}"
  else
    set -- "$@" --"${optname}=${optpath}"
  fi
done <<EOF
$(printf %s\\n "${DEPENDENCIES:-}")
EOF

# Now we can run
docker run "$@"
