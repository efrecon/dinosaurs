#!/bin/sh

set -eu

. "$(cd -L -- "$(dirname "$0")" && pwd -P)/../lib/utils.sh"

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


[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_SOURCE:-}" ] && printf "You must set DINO_SOURCE variable!" && exit 1
[ -z "${DINO_ARCH:-}" ] && printf "You must set DINO_ARCH variable!" && exit 1
[ -z "${DINO_VERSION:-}" ] && printf "You must set DINO_VERSION variable!" && exit 1
[ -z "${DINO_PROJECT:-}" ] && printf "You must set DINO_PROJECT variable!" && exit 1

verbose "Installing dependencies, requires admin privileges"
"${DINO_ROOTDIR%/}/${DINO_PROJECT}/docker/dependencies.sh"

verbose "Building and installing into $DINO_DEST"
mkdir -p "$DINO_DEST"

FLAGS=
if [ -n "${DINO_SHARED+unset}" ]; then
  if [ "${DINO_SHARED:-}" = "0" ]; then
    FLAGS=--static
  elif [ "${DINO_SHARED:-}" = "1" ]; then
    FLAGS=--shared
  fi
fi

set -- \
  "${DINO_ROOTDIR%/}/${DINO_PROJECT}/docker/build.sh" \
    --source "$DINO_SOURCE" \
    --destination "$(readlink_f "$DINO_DEST")" \
    --arch "$DINO_ARCH" \
    --steps "${DINO_STEPS:-}" \
    --verbose="$DINO_VERBOSE" \
    $FLAGS

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
      set -- "$@" --"${optname}=${optpath}"
      verbose "Passing extra option: --${optname}=${optpath}"
    fi
  fi
done <<EOF
$(printf %s\\n "${DINO_DEPENDENCIES:-}")
EOF

# symlink the content of the DINO_PREFIX variable into the docker container. Each
# directory is meant as the top of "include" and "lib" directories.
while IFS= read -r src; do
  if printf %s\\n "$src" | grep -q ':'; then
    tgt=$(printf %s\\n "$src" | cut -d: -f2)
    src=$(printf %s\\n "$src" | cut -d: -f1)
  else
    tgt=/usr
  fi
  if [ -d "$src" ]; then
    src=$(readlink_f "${src}")
    while IFS= read -r fpath; do
      rpath=$(printf %s\\n "$fpath" | sed "s~^${src%/}~~")
      mkdir -p "$(dirname "${tgt%/}/${rpath#/}")"
      ln -sf "${fpath}" "${tgt%/}/${rpath#/}"
    done <<EOF
$(find "$src" -type f)
EOF
  fi
done <<EOF
$(printf %s\\n "${DINO_PREFIX:-}")
EOF

"$@"

while IFS= read -r src; do
  if printf %s\\n "$src" | grep -q ':'; then
    tgt=$(printf %s\\n "$src" | cut -d: -f2)
    src=$(printf %s\\n "$src" | cut -d: -f1)
  else
    tgt=/usr
  fi
  if [ -d "$src" ]; then
    src=$(readlink_f "${src}")
    while IFS= read -r fpath; do
      rpath=$(printf %s\\n "$fpath" | sed "s~^${src%/}~~")
      rm -f "${tgt%/}/${rpath#/}"
    done <<EOF
$(find "$src" -type f)
EOF
  fi
done <<EOF
$(printf %s\\n "${DINO_PREFIX:-}")
EOF
