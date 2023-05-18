#!/bin/sh

# This file is meant to be sourced, not executed. Its behaviour will depend on
# the presence of some variables. In other words: depending on the variables
# that are set (to defaults) by the inlining script, options will be recognised,
# parsed and set those variables

# Root directory to construct the paths from. Defaults to the output directory
# under the root of the whole project.
ROOTDIR=${ROOTDIR:-"$(dirname "$(dirname "$(readlink_f "$0")")")"}
OUTDIR=${OUTDIR:-"${ROOTDIR%/}/output"}

DINO_PROJECT=${DINO_PROJECT:-"$(basename "$(dirname "$(readlink_f "$0")")")"}

DINO_VERBOSE=${DINO_VERBOSE:-0}

unknown() {
  if [ "${DINO_GRACEFULL:-0}" != "1" ]; then
    printf "Unknown option: %s\\n" "$1" >&2
    usage 1 >&2
  fi
}

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
  if [ -n "${STEPS+unset}" ]; then
    printf "  --steps LIST\\n"
    printf "\\tThe compilation steps to perform, a space-separated list of the following: configure build install clean\\n"
  fi
  if [ -n "${DOCKER+unset}" ]; then
    printf "  --docker (=0/1)\\n"
    printf "\\tForce building with Docker. When value passed, boolean for docker/host\\n"
  fi
  if [ -n "${DOCKER+unset}" ]; then
    printf "  --host\\n"
    printf "\\tForce building on the host.\\n"
  fi
  if [ -n "${DINO_PROJECT+unset}" ]; then
    printf "  -p, --proj, --project\\n"
    printf "\\tProject to work with, defaults to name of directory hosting binary\\n"
  fi
  if [ -n "${ARCHITECTURE+unset}" ]; then
    printf "  -a, --arch, --architecture\\n"
    printf "\\tArchitecture to build for, a dash separated pair, e.g. linux-i386\\n"
  fi
  printf "  -r, --root\\n"
  printf "\\tRoot directory to construct the paths from, defaults to the output directory under the root of the whole project\\n"
  printf "  --verbosity (=0/1)\\n"
  printf "\\tIncrease verbosity, or set it when used with equal\\n"
  printf "  -h, --help\\n"
  printf "\\tPrint this help and exit\\n"
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -v | --version) # The version of Tcl to build (also used for specifying the default directories)
      if [ -z "${VERSION+unset}" ]; then
        unknown "$1"; shift 2;
      else
        VERSION=$2; shift 2;
      fi
      ;;
    --version=*)
      if [ -z "${VERSION+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        VERSION="${1#*=}"; shift 1;
      fi
      ;;

    -d | --dest | --destination) # The destination directory.
      if [ -z "${DESTINATION+unset}" ]; then
        unknown "$1"; shift 2;
      else
        DESTINATION=$2; shift 2;
      fi
      ;;
    --dest=* | --destination=*)
      if [ -z "${DESTINATION+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        DESTINATION="${1#*=}"; shift 1;
      fi
      ;;

    -s | --src | --source) # The source directory.
      if [ -z "${SOURCE+unset}" ]; then
        unknown "$1"; shift 2;
      else
        SOURCE=$2; shift 2;
      fi
      ;;
    --src=* | --source=*)
      if [ -z "${SOURCE+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        SOURCE="${1#*=}"; shift 1;
      fi
      ;;

    --steps) # Compilation steps to perform
      if [ -z "${STEPS+unset}" ]; then
        unknown "$1"; shift 2;
      else
        STEPS=$2; shift 2;
      fi
      ;;
    --steps=*)
      if [ -z "${STEPS+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        STEPS="${1#*=}"; shift 1;
      fi
      ;;

    --shared)   # Force building of shared libraries if possible
      if [ -z "${SHARED+unset}" ]; then
        unknown "$1"; shift 1;
      else
        SHARED=1; shift 1;
      fi
      ;;
    --shared=*)
      if [ -z "${SHARED+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        SHARED="${1#*=}"; shift 1;
      fi
      ;;

    --static)   # Force building of static libraries if possible
      if [ -z "${SHARED+unset}" ]; then
        unknown "$1"; shift 1;
      else
        SHARED=0; shift 1;
      fi
      ;;

    --docker)   # Force building with docker
      if [ -z "${DOCKER+unset}" ]; then
        unknown "$1"; shift 1;
      else
        DOCKER=1; shift 1;
      fi
      ;;
    --docker=*)
      if [ -z "${DOCKER+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        DOCKER="${1#*=}"; shift 1;
      fi
      ;;

    --host)   # Force building directly on host
      if [ -z "${DOCKER+unset}" ]; then
        unknown "$1"; shift 1;
      else
        DOCKER=0; shift 1;
      fi
      ;;

    -a | --arch | --architecture) # The architecture to build for.
      if [ -z "${ARCHITECTURE+unset}" ]; then
        unknown "$1"; shift 2;
      else
        ARCHITECTURE=$2; shift 2;
      fi
      ;;
    --arch=* | --architecture=*)
      if [ -z "${ARCHITECTURE+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        ARCHITECTURE="${1#*=}"; shift 1;
      fi
      ;;

    -p | --proj | --project) # The name for the project to work with
      if [ -z "${DINO_PROJECT+unset}" ]; then
        unknown "$1"; shift 2;
      else
        DINO_PROJECT=$2; shift 2;
      fi
      ;;
    --proj=* | --project=*)
      if [ -z "${DINO_PROJECT+unset}" ]; then
        unknown "${1%=*}"; shift 1;
      else
        DINO_PROJECT="${1#*=}"; shift 1;
      fi
      ;;

    --root)
      OUTDIR=$2; shift 2;
      ;;
    --root=*)
      OUTDIR="${1#*=}"; shift 1;
      ;;

    -h | --help) # Show the help.
      usage;;

    --verbose) # Increase verbosity.
      DINO_VERBOSE=1; shift 1;;
    --verbose=*) # Increase verbosity.
      DINO_VERBOSE="${1#*=}"; shift 1;;

    --) shift; break;;

    -*) unknown "$1";;

    *) break;;
  esac
done
