#!/usr/bin/env bash

set -euo pipefail

# Originally based on install.sh from NVM
# https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh

{
  user_has () {
    type "$1" >/dev/null 2>&1
  }

  do_download () {
    if user_has "curl"; then
      curl -s -q --compressed "$@"
    elif user_has "wget"; then # LCOV_EXCL_LINE
      # Emulate curl with wget
      ARGS=$(echo "$*" | command sed -e 's/--compressed //' -e 's/-o /-O /' -e 's/-C - /-c /') # LCOV_EXCL_LINE
      # shellcheck disable=SC2086
      eval wget $ARGS # LCOV_EXCL_LINE
    fi
  }

  function install () {
    local version
    local install_to="/usr/local/bin/sind"

    if ! user_has "curl" && ! user_has "wget"; then # LCOV_EXCL_LINE
      echo >&2 "You must have curl or wget to use this install script." # LCOV_EXCL_LINE
      exit 65 # LCOV_EXCL_LINE
    elif [[ "$PATH" == *"termux"* ]]; then # LCOV_EXCL_LINE
      printf >&2 "This install script is not compatible with Termux." # LCOV_EXCL_LINE
      exit # LCOV_EXCL_LINE
    else
      version="$(do_download -s https://api.github.com/repos/l3laze/sind/releases/latest)";
      version="${version/*\"tag_name\": \"/}"
      version="${version/\"*/}"
      echo >&2 "Installing latest sind from GitHub @ $version for current user."

      do_download -o "$install_to" "https://raw.githubusercontent.com/l3laze/sind/${version}/sind.sh" || {
        echo >&2 "Failed to download sind.sh as $install_to" # LCOV_EXCL_LINE
        exit 68 # LCOV_EXCL_LINE
      }
    fi

    chmod u+x "$install_to" || { # LCOV_EXCL_LINE
      echo >&2 "Failed to chmod $install_to" # LCOV_EXCL_LINE
      exit 69 # LCOV_EXCL_LINE
    }

    # shellcheck source=/dev/null
    source "$HOME/.profile"

    if ! command -v sind >/dev/null 2>&1; then # LCOV_EXCL_LINE
      echo >&2 "Installation failed!" # LCOV_EXCL_LINE
      exit 70 # LCOV_EXCL_LINE
    else
      echo >&2 "Success."
      exit
    fi
  }

  install "$@"
}
