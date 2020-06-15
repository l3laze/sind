#!/usr/bin/env bash
#
# This script is based on code by Alexander Klimetschek at
# https://unix.stackexchange.com/a/415155/310780
#

set -euo pipefail

# From https://stackoverflow.com/a/42762743

hr () {
  printf '\n%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

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

  trap "stty echo > /dev/null 2>&1; cursor_on; exit 1" 2
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

commandline () {
  local version="2.0.0"
  local self="${BASH_SOURCE[0]}"
  local usage="USAGE: $(basename ${self##*/}) <command> <title> [opts]\n\
    mode  - "list" | "line".\n\
    title - Title/message above options.\n\
    opts  - 2+ space-separated options."

  if [[ "${1:-}" =~ (--)?version ]]; then
    echo >&2 "$version" && exit 1
  elif [[ "${1:-}" =~ (--)?help ]]; then
    echo -e >&2 "$usage" && exit 1
  elif [[ "$#" -lt 3 ]]; then
    echo -e >&2 "\nERROR: Not enough options.\n\n$usage\n\n" && exit 1
  elif [[ ! "$1" =~ ^(line|list)$ ]]; then
    echo -e >&2 "\nERROR: Unknown command \"$1\"\n\n$usage\n\n" && exit 1
  fi
}

sind () {
  commandline "$@"
  select_option "$@" 1>&2
  local result=$?
  shift; shift
  read -ra arr <<< "$@"
  echo "${arr[result]}"
}

# Error when called directly

if [[ $(basename -- "$0") == $(basename -- "${BASH_SOURCE[0]}") ]]; then
  if [[ "${1:-}" =~ (--)?(version) ]]; then
    commandline "$@" && exit 1
  else
    echo -e "\n${self##*/} - ERROR: This cannot be called directly." && exit 1
  fi
fi
