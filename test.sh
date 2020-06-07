#!/usr/bin/env bash

#
# Test script for sind
#
set -euo pipefail

# shellcheck disable=SC1091
source ./sind.sh

hr () {
  # From https://stackoverflow.com/a/42762743
  printf '\n%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}


#----


#: <<'END_COMMENT'

userChoice=$(sind "line" "Choose one...\nOf these." "  Yes   " "   No   " " Batman " " Cancel ")

printf "\033[1A"
hr
printf "Selected %s" "$userChoice"
hr


#----


#: <<'END_COMMENT'

userChoice=$(sind "list" "Choose one...\nOf these." "  Yes   " "   No   " " Batman " " Cancel ")

printf "\033[1A"
hr
printf "Selected %s" "$userChoice"
hr


#----


#: <<'END_COMMENT'

userChoice=$(sind "list" "Choose one...\nThis is a big title.\nMany lines.\nMuch words.\nVery wow." "  Yes   " "   No   " " Batman " " Cancel ")

printf "\033[1A"
hr
printf "Selected %s\n" "$userChoice"
