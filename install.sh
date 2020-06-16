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
    if ! user_has "curl" && ! user_has "wget"; then
      echo >&2 "You must have curl or wget to use this install script."
    fi

    local version
    version=$(do_download -s https://github.com/l3laze/sind/releases/latest) || {
      echo >&2 "Failed to fetch latest version info."
    }
    version=$(echo "$version" | awk -F \" '{print $2}' | awk -F \/ '{print $8}') || {
      echo >&2 "Failed to parse latest version info."
    }

    printf "Installing latest \"sind\" @ %s.\n" "$version"

    do_download -s -o "/usr/local/bin/sind" "https://raw.githubusercontent.com/l3laze/sind/""$version""/sind.sh" || {
      echo >&2 "Failed to download sind.sh"
    }

    chmod u+x "/usr/local/bin/sind" || {
      echo >&2 "Failed to chmod /usr/local/bin/sind"
    }

    if ! command -v sind > /dev/null 2>&1; then
      echo >&2 "Installation failed. Run for your life!"
      exit
    else
      echo "Success!"
    fi
  }

  install
}