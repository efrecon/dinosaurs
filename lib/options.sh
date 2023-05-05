#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables. In other words: depending on the variables
# that are set (to defaults) by the inlining script, options will be recognised,
# parsed and set those variables

# Root directory to construct the paths from. Will default to the current
ROOTDIR=${ROOTDIR:-$(pwd)}

unknown() { printf "Unknown option: %s\\n" "$1" >&2; usage 1 >&2; }

usage() {
  if [ -n "${USAGE:-}" ]; then
    printf "%s: %s\\n" "$0" "$USAGE"
  else
    printf "%s: dinosaurs tool\\n" "$0"
  fi
  if [ -n "${VERSION+unset}" ]; then
    printf "  -v, --version VERSION\\n"
    printf "\\tThe version to build (also used for specifying the default directories)\\n"
  fi
  if [ -n "${DESTINATION+unset}" ]; then
    printf "  -v, --dest, --destination PATH\\n"
    printf "\\tThe destination directory, will be automatically created if necessary\\n"
  fi
  if [ -n "${SOURCE+unset}" ]; then
    printf "  -s, --src, --source PATH\\n"
    printf "\\tThe source directory\\n"
  fi
  if [ -n "${SHARED+unset}" ]; then
    printf "  --shared (=0/1)\\n"
    printf "\\tForce building shared libraries if possible. When value passed, boolean for shared/static\\n"
  fi
  if [ -n "${SHARED+unset}" ]; then
    printf "  --static\\n"
    printf "\\tForce building static libraries if possible.\\n"
  fi
  if [ -n "${ARCHITECTURE+unset}" ]; then
    printf "  -a, --arch, --architecture\\n"
    printf "\\tArchitecture to build for, a dash separated pair, e.g. linux-i386\\n"
  fi
  printf "  -h, --help\\n"
  printf "\\tPrint this help and exit\\n"
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -v | --version) # The version of Tcl to build (also used for specifying the default directories)
      if [ -z "${VERSION+unset}" ]; then
        unknown "$1"
      else
        VERSION=$2; shift 2;
      fi
      ;;
    --version=*)
      if [ -z "${VERSION+unset}" ]; then
        unknown "${1%=*}"
      else
        VERSION="${1#*=}"; shift 1;
      fi
      ;;

    -d | --dest | --destination) # The destination directory.
      if [ -z "${DESTINATION+unset}" ]; then
        unknown "$1"
      else
        DESTINATION=$2; shift 2;
      fi
      ;;
    --dest=* | --destination=*)
      if [ -z "${DESTINATION+unset}" ]; then
        unknown "${1%=*}"
      else
        DESTINATION="${1#*=}"; shift 1;
      fi
      ;;

    -s | --src | --source) # The source directory.
      if [ -z "${SOURCE+unset}" ]; then
        unknown "$1"
      else
        SOURCE=$2; shift 2;
      fi
      ;;
    --src=* | --source=*)
      if [ -z "${SOURCE+unset}" ]; then
        unknown "${1%=*}"
      else
        SOURCE="${1#*=}"; shift 1;
      fi
      ;;

    --shared)   # Force building of shared libraries if possible
      if [ -z "${SHARED+unset}" ]; then
        unknown "$1"
      else
        SHARED=1; shift 1;
      fi
      ;;
    --shared=*)
      if [ -z "${SHARED+unset}" ]; then
        unknown "${1%=*}"
      else
        SHARED="${1#*=}"; shift 1;
      fi
      ;;

    --static)   # Force building of static libraries if possible
      if [ -z "${SHARED+unset}" ]; then
        unknown "$1"
      else
        SHARED=0; shift 1;
      fi
      ;;

    -a | --arch | --architecture) # The architecture to build for.
      if [ -z "${ARCHITECTURE+unset}" ]; then
        unknown "$1"
      else
        ARCHITECTURE=$2; shift 2;
      fi
      ;;
    --arch=* | --architecture=*)
      if [ -z "${ARCHITECTURE+unset}" ]; then
        unknown "${1%=*}"
      else
        ARCHITECTURE="${1#*=}"; shift 1;
      fi
      ;;

    --root)
      if [ -z "${ROOTDIR+unset}" ]; then
        unknown "$1"
      else
        ROOTDIR=$2; shift 2;
      fi
      ;;
    --root=*)
      if [ -z "${ROOTDIR+unset}" ]; then
        unknown "${1%=*}"
      else
        ROOTDIR="${1#*=}"; shift 1;
      fi
      ;;

    -h | --help) # Show the help.
      usage;;

    --) shift; break;;

    -*) unknown "$1";;

    *) break;;
  esac
done