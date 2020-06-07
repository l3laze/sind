#!/usr/bin/env bash
#
# Test script for sind
#

set -euo pipefail

# shellcheck disable=SC1091
source ./sind.sh
# shellcheck disable=SC1091
source ./hr.sh

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
esac