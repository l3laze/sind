#!/usr/bin/env bash
#
# From https://stackoverflow.com/a/42762743
#

hr () {
  printf '\n%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}
