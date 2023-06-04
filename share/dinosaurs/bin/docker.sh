#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../lib/utils.sh"

# Basename for the name of the image to build when not default.
DINO_IMG_BASE=${DINO_IMG_BASE:-"$DINO_PROJECT"}
# Fully qualified name of the image to build, by default uses a combination of
# the basename from above, the version and architecture.
DINO_IMG_NAME=${DINO_IMG_NAME:-}
# Protected "namespace" inside container under which we will mount local
# fully resolved directories.
DINO_IMG_NAMESPACE=${DINO_IMG_NAMESPACE:-"/opt/dinosaurs/mnt"}

# Several lines: each line is the name of an option that will be passed to the
# build command, e.g. with-tcl (sans the leading dashes), followed by an equal
# sign, then a path. When the path contains a colon, it is assumed to contain a
# pair. The first path is the directory to mount, the second the directory to
# give to the option. This allows to mount parent directories of the one that is
# passed to the option so they can still be found inside the container
DINO_DEPENDENCIES=${DINO_DEPENDENCIES:-""}

# Prefix should contain a list of directories (or pairs, separated by a colon
# sign) that are typically the --prefix target of another build. All **files**
# contained in these directories will be mountd inside the default prefix, i.e.
# /usr/local. When the specification is a pair, the second item contains the
# target prefix directory.
DINO_PREFIX=${DINO_PREFIX:-""}

# Set the usage message
USAGE="Build a project using a Docker image and container"

while [ $# -gt 0 ]; do
  case "$1" in
    -b | --base) # The basename to use, empty for project's name
      DINO_IMG_BASE=$2; shift 2;
      ;;
    --base=*)
      DINO_IMG_BASE="${1#*=}"; shift 1;
      ;;

    -i | --image) # The name of the image to build, empty for good default based on base, version and arch
      DINO_IMG_NAME=$2; shift 2;
      ;;
    --image=*)
      DINO_IMG_NAME="${1#*=}"; shift 1;
      ;;

    -n | --name | --namespace) # The rooted path namespace under which we will mount local directories
      DINO_IMG_NAMESPACE=$2; shift 2;
      ;;
    --name=* | --namespace=*)
      DINO_IMG_NAMESPACE="${1#*=}"; shift 1;
      ;;

    -d | --dependencies) # list of dependency options to pass to the build command, sans leading dashes
      DINO_DEPENDENCIES=$2; shift 2;
      ;;
    --dependencies=*)
      DINO_DEPENDENCIES="${1#*=}"; shift 1;
      ;;

    -p | --prefix) # List of directories to mount inside the prefix, files will be mounted one by one and recursively
      DINO_PREFIX=$2; shift 2;
      ;;
    --prefix=*)
      DINO_PREFIX="${1#*=}"; shift 1;
      ;;

    -h | --help) # Show the help
      usage;;

    --) shift; break;;

    -*) usage 1;;

    *) break;;
  esac
done

# Good default for the image name
[ -z "$DINO_IMG_NAME" ] && DINO_IMG_NAME="${DINO_IMG_BASE}${DINO_VERSION}-${DINO_ARCH}"

# Verify all our variables are set, these are typically automatically exported
# before this is called.
[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_SOURCE:-}" ] && printf "You must set DINO_SOURCE variable!" && exit 1
[ -z "${DINO_ARCH:-}" ] && printf "You must set DINO_ARCH variable!" && exit 1
[ -z "${DINO_VERSION:-}" ] && printf "You must set DINO_VERSION variable!" && exit 1
[ -z "${DINO_PROJECT:-}" ] && printf "You must set DINO_PROJECT variable!" && exit 1

# Create the destination directory if it doesn't exist
mkdir -p "$DINO_DEST"

verbose "Building Docker image: $DINO_IMG_NAME"
if [ -z "${UBUNTU_VERSION:-}" ]; then
  docker image build -f "${DINO_ROOTDIR%/}/${DINO_PROJECT}/docker/Dockerfile" \
    --build-arg "DINO_VERSION=${DINO_VERSION}" \
    --build-arg "DINO_SOURCE=${DINO_SOURCE}" \
    --build-arg "DINO_DEST=${DINO_DEST}" \
    --build-arg "DINO_PROJECT=${DINO_PROJECT}" \
    -t "$DINO_IMG_NAME" \
    "$DINO_ROOTDIR"
else
  docker image build -f "${DINO_ROOTDIR%/}/${DINO_PROJECT}/docker/Dockerfile" \
    --build-arg "DINO_VERSION=${DINO_VERSION}" \
    --build-arg "DINO_SOURCE=${DINO_SOURCE}" \
    --build-arg "DINO_DEST=${DINO_DEST}" \
    --build-arg "DINO_PROJECT=${DINO_PROJECT}" \
    --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" \
    -t "$DINO_IMG_NAME" \
    "$DINO_ROOTDIR"
fi

# Use the programs main argument vector to build arguments that will be passed
# to docker run.

# FIRST STEP: start with the arguments to docker run itself
abssrc=$(readlink_f "${DINO_SOURCE}"); # Resolve the source so we can remap it
set -- \
  --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(readlink_f "${DINO_DEST}"):/usr/local" \
  -v "$(readlink_f "${DINO_SOURCE}"):${DINO_IMG_NAMESPACE%/}/${abssrc#/}" \
  -w "${DINO_IMG_NAMESPACE%/}/${abssrc#/}"
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
    set -- "$@" -v "${optmnt}:${DINO_IMG_NAMESPACE%/}/${optmnt#/}"
  fi
done <<EOF
$(printf %s\\n "${DINO_DEPENDENCIES:-}")
EOF

# Mount the content of the DINO_PREFIX variable into the docker container. Each
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
$(printf %s\\n "${DINO_PREFIX:-}")
EOF

# SECOND STEP: image name and arguments to the entry point
set -- "$@" \
  "$DINO_IMG_NAME" \
    --source "${DINO_IMG_NAMESPACE%/}/${abssrc#/}" \
    --destination /usr/local \
    --arch "$DINO_ARCH" \
    --steps "${DINO_STEPS:-}" \
    --verbose="$DINO_VERBOSE"
if [ "${DINO_SHARED:-}" = "0" ]; then
  set -- "$@" --static
elif [ "${DINO_SHARED:-}" = "1" ]; then
  set -- "$@" --shared
fi
# Pick the dependencies again, use the same location as where they are remapped.
if [ -n "${DINO_DEPENDENCIES:-}" ]; then
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
      set -- "$@" --"${optname}=${DINO_IMG_NAMESPACE%/}/${optpath#/}"
      verbose "Passing extra option: --${optname}=${DINO_IMG_NAMESPACE%/}/${optpath#/}"
    else
      set -- "$@" --"${optname}=${optpath}"
      verbose "Passing extra option: --${optname}=${optpath}"
    fi
  fi
done <<EOF
$(printf %s\\n "${DINO_DEPENDENCIES:-}")
EOF

# THIRD STEP: Now we can run to create a container based on the image that we
# built at the beginning.
verbose "Running container based on Docker image: $DINO_IMG_NAME"
docker run "$@"
