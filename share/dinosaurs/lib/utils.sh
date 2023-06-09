#!/bin/sh

# PML: Poor Man's Logging
_log() {
    printf '[%s] [%s] [%s] %s\n' \
      "$(basename "$0")" \
      "${2:-LOG}" \
      "$(date +'%Y%m%d-%H%M%S')" \
      "${1:-}" \
      >&2
}
# shellcheck disable=SC2015 # We are fine, this is just to never fail
verbose() { [ "$DINO_VERBOSE" = "1" ] && _log "$1" NFO || true ; }
warning() { _log "$1" WRN; }
error() { _log "$1" ERR && exit 1; }


# Print usage out of content of main script and exit.
usage() {
  # This uses the comments behind the options to show the help. Not extremly
  # correct, but effective and simple.
  if [ -z "$USAGE" ]; then
    USAGE="a part of the dinosaurs project"
  fi
  printf "%s: %s\\n" "$(basename "$0")" "$USAGE" && \
    grep "[[:space:]]\-.*)\ #" "$0" |
    sed 's/#//' |
    sed 's/)/\t/'
  printf \\nEnvironment:\\n
  set | grep '^DINO_' | sed 's/^DINO_/    DINO_/g'
  exit "${1:-0}"
}


# Download the url passed as the first argument to the destination path passed
# as a second argument. The destination will be the same as the basename of the
# URL, in the current directory, if omitted.
download() {
  verbose "Downloading $1 to ${2:-$(basename "$1")}"
  if command -v curl >/dev/null; then
    curl -sSL -o "${2:-$(basename "$1")}" "$1"
  elif command -v wget >/dev/null; then
    wget -q -O "${2:-$(basename "$1")}" "$1"
  else
    printf "You need curl or wget installed to download files!\n" >&2
    exit 1
  fi
}

tolower() { tr '[:upper:]' '[:lower:]'; }

_libc() {
  # Find out what this process is linked to. Extract using the command line
  # under /proc. See: https://stackoverflow.com/a/70990245
  if ldd "$(command -v "$(awk 'BEGIN{FS="\x00"}{print$1}' < /proc/self/cmdline)")" | grep -q musl; then
    printf "musl\n"
  else
    printf "glibc\n"
  fi
}

architecture() { printf %s-unknown-%s-%s\\n "$(uname -m | tolower)" "$(uname -s | tolower)" "$(_libc)"; }

if_sudo() {
  if [ "$(id -u)" -ne "0" ]; then
    SUDO=$(command -v sudo 2>/dev/null)
    if ! [ -x "$SUDO" ]; then
      printf "You need sudo installed to run this command!\n" >&2
      exit 1
    fi

    "$SUDO" "$@"
  else
    "$@"
  fi
}

os_version() (
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf %s\\n "$VERSION_ID"
  elif [ -r /etc/lsb-release ]; then
    # shellcheck disable=SC1091
    . /etc/lsb-release
    printf %s\\n "$DISTRIB_RELEASE"
  fi
)

repoint_sources_list() {
  case "$(os_version)" in
    14.04* | 16.04* | 18.04* | 2?.04*)
      ;;  # Modern LTS Ubuntu do nothing
    2[2-9].*)
      ;;  # Modern Ubuntu, do nothing
    *)
      SRC_LIST=$(mktemp)
      sed s/archive/old-releases/g /etc/apt/sources.list > "$SRC_LIST"
      if_sudo mv "$SRC_LIST" /etc/apt/sources.list
      ;;
  esac
}

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

version() { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

html2ascii() { sed -E -e 's/<[^>]+>//g' -e 's/&[[:alpha:]]+;//g'; }