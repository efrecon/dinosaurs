#!/bin/sh

# Download the url passed as the first argument to the destination path passed
# as a second argument. The destination will be the same as the basename of the
# URL, in the current directory, if omitted.
download() {
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

architecture() { printf %s-%s\\n "$(uname -s | tolower)" "$(uname -m | tolower)"; }

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
  . /etc/os-release
  printf %s\\n "$VERSION_ID"
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