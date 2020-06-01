#!/usr/bin/env bash

#
# Test script for sind
#
set -euo pipefail

source ./sind.sh

userChoice=$(sind "Choose one" "  Yes   " "   No   " " Batman " " Cancel ")
case "$userChoice" in
  0) echo "selected Yes";;
  1) echo "selected No";;
  2) echo "selected Batman";;
  3) echo "selected Cancel";;
esac

userChoice=$(sind $'Choose one...\nFrom this...\nHere list...' "  Yes   " "   No   " " Batman " " Cancel ")
case "$userChoice" in
  0) echo "selected Yes";;
  1) echo "selected No";;
  2) echo "selected Batman";;
  3) echo "selected Cancel";;
esac