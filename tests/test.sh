#!/usr/bin/env bash
#
# Test script for sind

set -euo pipefail

# shellcheck disable=SC1091
source ./sind.sh

# From https://stackoverflow.com/a/42762743

hr () {
  printf '\n%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

if [[ ! "$1" =~ [[:digit:]]+ ]]; then
  echo >&2 "Not a number: $1"
fi

case "$1" in
  1)
    userChoice=$(sind "line" "Choose one...\nOf these." "  Yes   " "   No   " " Batman " " Cancel ")
    hr
    printf "Selected %s\n" "$userChoice"
  ;;

  2)
    userChoice=$(sind "list" "Choose one...\nOf these." "  Yes   " "   No   " " Batman " " Cancel ")
    hr
    printf "Selected %s\n" "$userChoice"
  ;;

  3)
    userChoice=$(sind "list" "Choose one...\nThis is a big title.\nMany lines.\nMuch words.\nVery wow." "  Yes   " "   No   " " Batman " " Cancel ")
    hr
    printf "Selected %s\n" "$userChoice"
  ;;

  4)
    userChoice=$(sind "version" "Choose one...\nThis is the title." "One" "Two")
    # Should print version.
  ;;

  5)
    userChoice=$(sind "help" "Choose one...\nThis is the title." "One" "Two")
    # Should print usage.
  ;;

  6)
    userChoice=$(sind "Title." "  Yes   " "   No   " " Batman " " Cancel ")
    # Should error: unknown command.
  ;;

  7)
    userChoice=$(sind "line" "Choose one...\nThis is the title.")
    # Should error: not enough options.
  ;;

  *)
    echo "Invalid test number: $1"
esac