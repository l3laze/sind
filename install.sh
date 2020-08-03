#!/usr/bin/env bash

# Originally based on install.sh from NVM
# https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh
{
  user_has () {
    type "$1" >/dev/null 2>&1
  }

  do_download () {
    if user_has "curl"; then
      curl -q --compressed "$@"
    elif user_has "wget"; then
      # Emulate curl with wget
      ARGS=$(echo "$*" | command sed -e 's/--compressed //' -e 's/-o /-O /' -e 's/-C - /-c /') # LCOV_EXCL_LINE
      # shellcheck disable=SC2086
      eval wget $ARGS # LCOV_EXCL_LINE
    fi
  }

  function install () {
    local from
    local to="/usr/local/bin"
    local tmp
    local version

    printf -v tmp "%s/sind.sh" "${0%/*}"
    mkdir -p "${to}"

    if [[ -e "$tmp" ]]; then
      from="local copy"
      echo >&2 "Installing sind for current user from $from."
      cp "$tmp" "${to}/sind"
    elif ! user_has "curl" && ! user_has "wget"; then
      echo >&2 "You must have curl or wget to use this install script." # LCOV_EXCL_LINE
      exit 65 # LCOV_EXCL_LINE
    else
      from="GitHub"
      version=$(do_download -s \
"https://api.github.com/repos/l3laze/sind/releases/latest")
      version="${version/*\"tag_name\": \"/}"
      version="${version/\"*/}"
      echo >&2 "Installing latest sind from $from @ $version for current user."
      do_download -s -o "$to/sind" "https://raw.githubusercontent.com/l3laze/sind/${version}/sind.sh" || {
        echo >&2 "Failed to download sind.sh as $to/sind" # LCOV_EXCL_LINE
        exit 68 # LCOV_EXCL_LINE
      }
    fi

    chmod u+x "$to/sind" || {
      echo >&2 "Failed to chmod $to/sind" # LCOV_EXCL_LINE
      exit 69 # LCOV_EXCL_LINE
    }

    if ! command -v sind >/dev/null 2>&1; then
      echo >&2 "Installation failed!" # LCOV_EXCL_LINE
      exit 70 # LCOV_EXCL_LINE
    else
      echo >&2 "Success."
    fi
  }

  install "$@"
}
