#!/usr/bin/env bash

#
# Test script for sind
#
set -euo pipefail

source ./sind.sh

hr () {
  # From https://stackoverflow.com/a/42762743
  printf '\n%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# : <<'END_COMMENT'
# END_COMMENT

userChoice=$(sind "Choose one..." "  Yes   " "   No   " " Batman " " Cancel ")

hr

echo "Selected $userChoice"

: <<'END_COMMENT'

sleep 1s

userChoice=$(sind $'Choose one...\nThis is a big title.\nMany lines.\nMuch words.\nVery wow.' "  Yes   " "   No   " " Batman " " Cancel ")

hr

echo "Selected $userChoice"

sleep 1s

while true; do

  userChoice=$(sind "Choose one (No = loop)..." "  Yes   " "   No   " " Batman " " Cancel ")

  case $userChoice in
    'Yes')
      hr
      echo 'Good... Good.'
      break
    ;;
  
    'Batman')
      hr
      echo 'I am the night.'
      break
    ;;
  
    'Cancel')
      hr
      echo 'Fine...'
      break
    ;;

    *)
    ;;
  esac
done

END_COMMENT