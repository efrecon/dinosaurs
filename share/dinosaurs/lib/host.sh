#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables. NOTE: It DESTROYS the program's argument
# vector to be able to operate.

[ -z "${DINO_DEST:-}" ] && printf "You must set DINO_DEST variable!" && exit 1
[ -z "${DINO_SOURCE:-}" ] && printf "You must set DINO_SOURCE variable!" && exit 1
[ -z "${DINO_ARCH:-}" ] && printf "You must set DINO_ARCH variable!" && exit 1
[ -z "${DINO_VERSION:-}" ] && printf "You must set DINO_VERSION variable!" && exit 1
[ -z "${DINO_PROJECT:-}" ] && printf "You must set DINO_PROJECT variable!" && exit 1


verbose "Installing dependencies, requires admin privileges"
"$(dirname "$(readlink_f "$0")")/docker/dependencies.sh"

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
  "$(dirname "$(readlink_f "$0")")/docker/entrypoint.sh" \
    --source "$DINO_SOURCE" \
    --destination "$(readlink_f "$DINO_DEST")" \
    --arch "$DINO_ARCH" \
    --steps "${DINO_STEPS:-}" \
    --verbose="$DINO_VERBOSE" \
    $FLAGS

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
      set -- "$@" --"${optname}=${optpath}"
      verbose "Passing extra option: --${optname}=${optpath}"
    fi
  fi
done <<EOF
$(printf %s\\n "${DEPENDENCIES:-}")
EOF

# symlink the content of the PREFIX variable into the docker container. Each
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
$(printf %s\\n "${PREFIX:-}")
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
$(printf %s\\n "${PREFIX:-}")
EOF
