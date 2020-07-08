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
    elif user_has "wget"; then
      # Emulate curl with wget
      ARGS=$(echo "$*" | command sed -e 's/--compressed //' -e 's/-o /-O /' -e 's/-C - /-c /')
      # shellcheck disable=SC2086
      eval wget $ARGS
    fi
  }

  function install () {
    local uselocal=1
    local testing=1
    local from
    local tmp

    tmp=$(dirname "$0")/"sind.sh"

    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -l|--local)
          uselocal=0
          shift
        ;;
        -t|--test)
          testing=0
          shift
        ;;
        *)
          echo >&2 "Error - unknown option $1"
          exit 64
      esac
    done

    if [[ "$uselocal" -ne 1 && -e "$tmp" ]]; then
      echo >&2 "Installing from local copy."
      from="local copy"
      cp "$tmp" /usr/local/bin/sind
    elif ! user_has "curl" && ! user_has "wget"; then
      echo >&2 "You must have curl or wget to use this install script."
      exit 65
    else
      from="GitHub"
      local version
      version=$(do_download -s https://github.com/l3laze/sind/releases/latest) || {
        echo >&2 "Failed to fetch latest version info."
        exit 66
      }
      version=$(echo "$version" | awk -F \" '{print $2}' | awk -F / '{print $8}') || {
        echo >&2 "Failed to parse latest version info."
        exit 67
      }

      echo -e >&2 "Installing latest \"sind\" from $from @ $version.\n"

      do_download -s -o "/usr/local/bin/sind" "https://raw.githubusercontent.com/l3laze/sind/""$version""/sind.sh" || {
        echo >&2 "Failed to download sind.sh as /usr/local/bin/sind"
        exit 68
      }
    fi

    chmod u+x "/usr/local/bin/sind" || {
      echo >&2 "Failed to chmod /usr/local/bin/sind"
      exit 69
    }

    if ! command -v sind > /dev/null 2>&1; then
      echo >&2 "Installation failed!"
      exit 70
    else
      echo "Installation from $from was successful!"
    fi

    if [[ "$testing" -ne 1 ]]; then rm /usr/local/bin/sind; fi
  }

  install "$@"
}
