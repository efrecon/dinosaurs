#!/bin/sh

set -eu

. "$(dirname "$0")/share/dinosaurs/utils.sh"

# Chain of sub-tools to call
DINO_CHAIN=${DINO_CHAIN:-"fetch build pack"}

DINO_VERBOSE=${DINO_VERBOSE:-0}

usage() {
  # This uses the comments behind the options to show the help. Not extremly
  # correct, but effective and simple.
  printf "%s call the other tools in turns\\n" "$0" && \
    grep "[[:space:]]\-.*)\ #" "$0" |
    sed 's/#//' |
    sed 's/)/\t/'
  exit "${1:-0}"
}


while [ $# -gt 0 ]; do
  case "$1" in
    -c | --chain) # The chain of sub-tools to call
      DINO_CHAIN=$2; shift 2;
      ;;
    --chain=*)
      DINO_CHAIN="${1#*=}"; shift 1;
      ;;

    -v | --verbose) # Turn up (or set with =) verbosity
      DINO_VERBOSE=1; shift;
      ;;
    --verbose=*)
      DINO_VERBOSE"${1#*=}"; shift;
      ;;

    -h | --help) # Show the help
      usage;;

    --) shift; break;;

    -*) usage 1;;

    *) break;;
  esac
done

DINO_PROJ=${1:-}; shift 1;
if [ -z "${DINO_PROJ}" ]; then
  printf "You must specify the name of a known project (subdirs)\n"; exit 1;
fi

if ! [ -d "$(dirname "$0")/$DINO_PROJ" ]; then
  printf "Unknown project: %s\n" "$DINO_PROJ"; exit 1;
fi

for DINO_SUBTOOL in $DINO_CHAIN; do
  if [ -x "$(dirname "$0")/$DINO_PROJ/${DINO_SUBTOOL}.sh" ]; then
    verbose "Running $DINO_PROJ/${DINO_SUBTOOL}.sh"
    DINO_GRACEFULL=1 "$(dirname "$0")/$DINO_PROJ/${DINO_SUBTOOL}.sh" --verbose="$DINO_VERBOSE" "$@"
  fi
done