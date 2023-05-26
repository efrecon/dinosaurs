#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables. NOTE: It DESTROYS the program's argument
# vector to be able to operate.

[ -z "${DESTINATION:-}" ] && printf "You must set DESTINATION variable!" && exit 1
[ -z "${SOURCE:-}" ] && printf "You must set SOURCE variable!" && exit 1
[ -z "${ARCHITECTURE:-}" ] && printf "You must set ARCHITECTURE variable!" && exit 1
[ -z "${VERSION:-}" ] && printf "You must set VERSION variable!" && exit 1
[ -z "${DINO_PROJECT:-}" ] && printf "You must set DINO_PROJECT variable!" && exit 1

# Basename for the name of the image to build when not default.
IMG_BASE=${IMG_BASE:-"$DINO_PROJECT"}
# Fully qualified name of the image to build, by default uses a combination of
# the basename from above, the version and architecture.
IMG_NAME=${IMG_NAME:-"${IMG_BASE}${VERSION}-${ARCHITECTURE}"}
# Protected "namespace" inside container under which we will mount local
# fully resolved directories.
IMG_NAMESPACE=${IMG_NAMESPACE:-"/opt/dinosaurs/mnt"}


mkdir -p "$DESTINATION"

verbose "Building Docker image: $IMG_NAME"
if [ -z "${UBUNTU_VERSION:-}" ]; then
  docker image build -f "$(readlink_f "$(dirname "$0")/docker/Dockerfile")" \
    --build-arg "VERSION=${VERSION}" \
    --build-arg "SOURCE=${SOURCE}" \
    --build-arg "DESTINATION=${DESTINATION}" \
    --build-arg "DINO_PROJECT=${DINO_PROJECT}" \
    -t "$IMG_NAME" \
    "$(dirname "$(readlink_f "$0")")/.."
else
  docker image build -f "$(readlink_f "$(dirname "$0")/docker/Dockerfile")" \
    --build-arg "VERSION=${VERSION}" \
    --build-arg "SOURCE=${SOURCE}" \
    --build-arg "DESTINATION=${DESTINATION}" \
    --build-arg "DINO_PROJECT=${DINO_PROJECT}" \
    --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" \
    -t "$IMG_NAME" \
    "$(dirname "$(readlink_f "$0")")/.."
fi

# Use the programs main argument vector to build arguments that will be passed
# to docker run.

# FIRST STEP: start with the arguments to docker run itself
abssrc=$(readlink_f "${SOURCE}"); # Resolve the source so we can remap it
set -- \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(readlink_f "${DESTINATION}"):/usr/local" \
  -v "$(readlink_f "${SOURCE}"):${IMG_NAMESPACE%/}/${abssrc#/}" \
  -w "${IMG_NAMESPACE%/}/${abssrc#/}"
# Dependencies should be written as name of option (without leading double
# dash), followed by an equal sign and the path to the dependency (no quotes).
# We remap them inside a directory that we can "own". See below for special case
# of : in path.
while IFS='=' read -r optname optpath; do
  # When the path contains a colon, it is assumed to contain a pair. The first
  # path is the directory to mount, the second the directory to give to the
  # option. This allows to mount parent directories of the one that is passed to
  # the option so they can still be found inside the container.
  if printf %s\\n "$optpath" | grep -q ':'; then
    optmnt=$(printf %s\\n "$optpath" | cut -d: -f1)
    optpath=$(printf %s\\n "$optpath" | cut -d: -f2)
  else
    optmnt="$optpath"
  fi

  # Arrange for Docker mount under namespaced directory if value was path to
  # file or directory.
  if [ -e "$optmnt" ]; then
    optmnt=$(readlink_f "${optmnt}")
    set -- "$@" -v "${optmnt}:${IMG_NAMESPACE%/}/${optmnt#/}"
  fi
done <<EOF
$(printf %s\\n "${DEPENDENCIES:-}")
EOF

# Mount the content of the PREFIX variable into the docker container. Each
# directory is meant as the top of "include" and "lib" directories.
while IFS= read -r src; do
  if printf %s\\n "$src" | grep -q ':'; then
    tgt=$(printf %s\\n "$src" | cut -d: -f2)
    src=$(printf %s\\n "$src" | cut -d: -f1)
  else
    tgt=/usr
  fi
  # Arrange for Docker mount under namespaced directory if value was path to
  # file or directory.
  if [ -d "$src" ]; then
    src=$(readlink_f "${src}")
    while IFS= read -r fpath; do
      rpath=$(printf %s\\n "$fpath" | sed "s~^${src%/}~~")
      set -- "$@" -v "${fpath}:${tgt%/}/${rpath#/}"
    done <<EOF
$(find "$src" -type f)
EOF
  fi
done <<EOF
$(printf %s\\n "${PREFIX:-}")
EOF

# SECOND STEP: image name and arguments to the entry point
set -- "$@" \
  "$IMG_NAME" \
    --source "${IMG_NAMESPACE%/}/${abssrc#/}" \
    --destination /usr/local \
    --arch "$ARCHITECTURE" \
    --steps "${STEPS:-}" \
    --verbose="$DINO_VERBOSE"
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
  if [ -n "$optname" ]; then
    if printf %s\\n "$optpath" | grep -q ':'; then
      optmnt=$(printf %s\\n "$optpath" | cut -d: -f1)
      optpath=$(printf %s\\n "$optpath" | cut -d: -f2)
    else
      optmnt="$optpath"
    fi

    # If value was path to file or directory, remap it to the namespaced directory
    # mounted above, otherwise pass it as-is.
    if [ -e "$optpath" ]; then
      optpath=$(readlink_f "${optpath}")
      set -- "$@" --"${optname}=${IMG_NAMESPACE%/}/${optpath#/}"
      verbose "Passing extra option: --${optname}=${IMG_NAMESPACE%/}/${optpath#/}"
    else
      set -- "$@" --"${optname}=${optpath}"
      verbose "Passing extra option: --${optname}=${optpath}"
    fi
  fi
done <<EOF
$(printf %s\\n "${DEPENDENCIES:-}")
EOF

# THIRD STEP: Now we can run to create a container based on the image that we
# built at the beginning.
verbose "Running container based on Docker image: $IMG_NAME"
docker run "$@"
