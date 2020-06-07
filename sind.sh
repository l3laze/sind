#!/usr/bin/env bash
#
# This script is based on code by Alexander Klimetschek at
# https://unix.stackexchange.com/a/415155/310780
#

set -e

# shellcheck disable=SC1091
source ./hr.sh

select_option () {
  stty -echo
  local ESC
  ESC=$'\033'

  cursor_on ()  { printf "%s" "${ESC}[?25h"; }

  cursor_off () { printf "%s" "${ESC}[?25l"; }

  print_option ()     { printf "%s" "$1"; }

  print_selected ()   { printf "%s" "${ESC}[7m$1${ESC}[27m"; }

  key_input () {
    local IFS=;
    local key

    while true; do
      read -rsN 1
      key=$REPLY

      if [[ "$key" == $'\n' ]]; then echo "enter"; break; fi
      if [[ "$key" == $'\t' ]]; then echo "tab"; break; fi
      if [[ "$key" == $'\b' ]]; then echo "backspace"; break; fi
      if [[ "$key" == 'j' ]]; then echo "up"; break; fi
      if [[ "$key" == 'k' ]]; then echo "down"; break; fi
      if [[ "$key" == "${ESC}" ]]; then
        # Read 2 more bytes in case it's an escape sequence
        read -rsN 2 -t 0.01

        [[ "$REPLY" != "" ]] && key+="$REPLY"
        if [[ "$key" == "${ESC}[A" ]]; then echo "up"; break; fi
        if [[ "$key" == "${ESC}[B" ]]; then echo "down"; break; fi
        if [[ "$key" == "${ESC}" ]]; then echo "esc"; break; fi

        key=;
      fi
    done
  }

  trap "stty echo > /dev/null 2>&1; cursor_on; exit" 2
  cursor_off

  local selected=1
  local idx
  local directions="(↑/j or ↓/k, Enter to choose)"
  local title
  title=$(echo -e "$2")

  local mode="$1"
  shift; shift

  local args
  read -ra args <<< "$@"

  printf "%s" "$title"
  hr
  printf "%s\n" "$directions"

  if [ "$mode" != "line" ]; then
    printf "%s\n" "${args[@]}"
  fi

  while true; do
    if [ "$mode" != "line" ]; then
      printf "\033[%sA\033[2K" "$((${#args} + 1))"
      idx=1

      for opt in "${args[@]}"; do
        printf "\033[1B\033[1000D\033[2K"
        if [ "$idx" -eq "$selected" ]; then
          print_selected "$opt"
        else
          print_option "$opt"
        fi

        ((idx++))
      done
    else
      printf "\033[2K\033[1000D"
      print_selected "${args[$((selected - 1))]}"
    fi

    case $(key_input) in
      enter) break;;
      up)
        ((selected--));
        if [ "$selected" -lt 1 ]; then selected=$(($#)); fi
      ;;
      down)
        ((selected++));
        if [ "$selected" -gt $# ]; then selected=1; fi
      ;;
      *)
      ;;
    esac
  done

  stty echo > /dev/null 2>&1
  printf "\n\033[1A"
  cursor_on

  return $((selected - 1))
}

sind () {
  if [[ "$#" -lt 3 ]]; then
    printf "\nERROR: Not enough arguments.\n\n"
    exit
  fi

  select_option "$@" 1>&2
  local result=$?
  shift; shift
  read -ra arr <<< "$@"
  echo "${arr[result]}"
}
