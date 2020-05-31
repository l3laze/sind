#!/usr/bin/env bash

#
# Test script for sind
#
set -euo pipefail

source ./sind.sh

hr () {
  # From https://stackoverflow.com/a/42762743
  printf '\n%*s\n\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

userChoice=$(sind "Choose one (↑/j or ↓/k, Enter to choose)" "  Yes   " "   No   " " Batman " " Cancel ")

hr

echo -e "Selected $userChoice"

hr
