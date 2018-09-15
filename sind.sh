#!/usr/bin/env bash

# This script is based on code by Alexander Klimetschek at
# https://unix.stackexchange.com/a/415155/310780
#
# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
function select_option {
  stty -echo
  # little helpers for terminal print control and key input
  ESC=$(printf "\033")
  cursor_blink_on()  { printf "%s" "${ESC}[?25h"; }
  cursor_blink_off() { printf "%s" "${ESC}[?25l"; }
  cursor_to()        { printf "%s" "${ESC}[$1;${2:-1}H"; }
  print_option()     { printf "%s" " $1 "; }
  print_selected()   { printf "%s" " ${ESC}[7m $1 ${ESC}[27m"; }
  get_cursor_row()   { IFS=';' read -rsdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; echo "$COL" > /dev/null; }
  key_input()        {
    IFS=;
    local key

    while true; do
      read -rsN 1 # Read first byte of key
      key=$REPLY

      if [[ $key == $'\n' ]]; then echo "enter"; break; fi
      if [[ $key == $'\t' ]]; then echo "tab"; break; fi
      if [[ $key == "${ESC}" ]]; then
        # Read 2 more bytes if it's an escape sequence, or nothing if it's just Esc.
        read -rsN 2 -t 0.001
        
        [[ $REPLY != "" ]] && key+=$REPLY
        if [[ $key == ${ESC}[A ]]; then echo "up"; break; fi
        if [[ $key == ${ESC}[B ]]; then echo "down"; break; fi
        if [[ $key == "${ESC}" ]]; then echo "esc"; break; fi

        key=;
      fi
    done
  }

  # ensure cursor and input echoing back on upon a ctrl+c during read -s
  trap "stty echo > /dev/null 2>&1; cursor_blink_on; exit" 2
  cursor_blink_off

  local selected=1
  local title="$1"
  shift

  clear
  printf "%s" "$title"

  while true; do
    # print options by overwriting the last lines from title down
    local idx=1
    for opt; do
      cursor_to $((idx + 1))
      printf '\e[2K' # Erase current line.
      if [ $idx -eq $selected ]; then
        print_selected "$opt"
      else
        print_option "$opt"
      fi
      printf '\n'
      ((idx++))
    done

    # user key control
    case $(key_input) in
      enter) break;;
      up)
        ((selected--));
        if [ $selected -lt 1 ]; then selected=$(($#)); fi
      ;;
      down)
        ((selected++));
        if [ $selected -gt $# ]; then selected=1; fi
      ;;
      *)
      ;;
    esac
  done

  # cursor position and echo back to normal
  stty echo > /dev/null 2>&1
  printf "\n"
  cursor_blink_on

  return $((selected - 1))
}

function sind {
  select_option "$@" 1>&2
  local result=$?
  echo $result
}