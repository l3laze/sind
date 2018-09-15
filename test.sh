#!/usr/bin/env bash

#
# Test script for sind
#

. ./sind.sh

userChoice=$(sind "Choose one (Up/Down, Enter to choose)" "Yes" "No" "Batman" "Cancel")
case "$userChoice" in
  0) echo "selected Yes";;
  1) echo "selected No";;
  2) echo "selected Batman";;
  3) echo "selected Cancel";;
esac