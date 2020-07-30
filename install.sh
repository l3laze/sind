#!/usr/bin/env bash

#
# Based on install.sh from NVM
# https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh
#

{
  user_has () {
    type "$1" > /dev/null 2>&1
  }

  do_download () {
    if user_has "curl"; then
      curl -q --compressed "$@"
    elif user_has "wget"; then # LCOV_EXCL_LINE
      # Emulate curl with wget
      ARGS=$(echo "$*" | command sed -e 's/--compressed //' -e 's/-o /-O /' -e 's/-C - /-c /') # LCOV_EXCL_LINE
      # shellcheck disable=SC2086
      eval wget $ARGS # LCOV_EXCL_LINE
    fi
  }

  function install () {
    local uselocal=1
    local testing=1
    local from
    local to="${HOME}/bin"
    local type="for current user"
    local tmp

    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -l|--local)
          uselocal=0
          printf >&2 "%s/sind.sh" "${0%/*}"
          tmp=$(dirname "$0")/"sind.sh"
          shift
        ;;
        -t|--test)
          testing=0
          shift
        ;;
        -s|--system)
          to="/usr/local/bin"
          type="globally"
          shift
        ;;
        *)
          echo >&2 "Error - unknown option: $1"
          exit 64
      esac
    done

    mkdir -p "${to}"

    if [[ "$uselocal" -ne 1 && -e "$tmp" ]]; then
      echo >&2 "Installing $type from local copy."
      from="local copy"
      cp "$tmp" "${to}/sind"
    elif ! user_has "curl" && ! user_has "wget"; then
      echo >&2 "You must have curl or wget to use this install script." # LCOV_EXCL_LINE
      exit 65 # LCOV_EXCL_LINE
    else
      from="GitHub"
      local version
      version=$(do_download -s https://github.com/l3laze/sind/releases/latest) || {
        echo >&2 "Failed to fetch latest version info." # LCOV_EXCL_LINE
        exit 66 # LCOV_EXCL_LINE
      }
      version=$(echo "$version" | awk -F \" '{print $2}' | awk -F / '{print $8}') || {
        echo >&2 "Failed to parse latest version info." # LCOV_EXCL_LINE
        exit 67 # LCOV_EXCL_LINE
      }

      echo -e >&2 "Installing latest \"sind\" from $from @ $version $type."

      do_download -s -o "$to/sind" "https://raw.githubusercontent.com/l3laze/sind/""$version""/sind.sh" || {
        echo >&2 "Failed to download sind.sh as $to/sind" # LCOV_EXCL_LINE
        exit 68 # LCOV_EXCL_LINE
      }
    fi

    chmod u+x "$to/sind" || {
      echo >&2 "Failed to chmod $to/sind" # LCOV_EXCL_LINE
      exit 69 # LCOV_EXCL_LINE
    }

    if [[ ! "${HOME}/bin" = *"$PATH"* ]]; then
       # shellcheck source=/dev/null
      source "$HOME/.profile" >/dev/null 2>&1
    fi

    if ! command -v sind > /dev/null 2>&1; then
      echo >&2 "Installation failed!" # LCOV_EXCL_LINE
      exit 70 # LCOV_EXCL_LINE
    else
      echo "Installation from $from was successful!"
    fi

    if [[ "$testing" -ne 1 ]]; then rm "$to/sind"; fi
  }

  install "$@"
}
