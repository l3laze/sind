#!/usr/bin/env bash

{
  set -euo pipefail

  #
  # Follows the suggested exit code range of 0 & 64-113
  # from http://www.tldp.org/LDP/abs/html/exitcodes.html
  #
  # | Exit Code | Meaning |
  # |    ---    |   ---   |
  # |     0     |  No errors. |
  # |    64     |  Unknown option. |
  # |    65     |  Not enough args for option. |
  # |    ---    |  --- |

  key_input () {
    local key
    IFS=; read -rsN 1
    key="$REPLY"

      if [[ "$key" =~ ^[A-Za-z0-9]$ ]]; then printf "%s" "$key";
    elif [[ "$key" == $'\n' ]]; then printf "enter";
    elif [[ "$key" == $' ' ]]; then printf "space";
    elif [[ "$key" == $'\e' ]]; then
      # Try to read 2 more bytes in case it's an escape sequence
      # 4-byte sequences would require another layer of handling..
      IFS=; read -rsN 2 -t 0.01
        if [[ "$REPLY" == "[A" ]]; then printf "up";
      elif [[ "$REPLY" == "[B" ]]; then printf "down";
      fi
      key=;
    fi
  }
  cursor_on ()  { printf >&2 "\e[?25h"; }
  cursor_off () { printf >&2 "\e[?25l"; }
  hr () { printf -v horule '%*s' "${COLUMNS:-$(tput cols)}" ''; printf >&2 "%s" "${horule// /-}"; }
  print_selected () { printf >&2 "%s" $'\e[7m'"$1"$'\e[27m'; }

  sind () {
    local version="5.0.0b"
    local opts
    local selected=0
    local title
    local choices=","
    local no_cancel=1
    local has_cancel=1
    local multiple=1
    local index=0
    local size=0
    local usage

    opts=()
    usage="USAGE\n\n$0 -t 'Required title' [options...]"

    cleanup () {
      printf >&2 "\e[%sB\n" "${#opts[@]}"
      hr
      printf >&2 "Cancel\n"
      cursor_on
      exit "${1:-0}"
    }

    trap "cleanup" HUP INT QUIT ABRT
    cursor_off

    while [[ "$#" -gt 0 ]]; do
      case "${1:-}" in
        -t|--title)
          if [[ "$#" -lt 2 ]]; then
            echo >&2 "Error - The -t|--title option needs an arg."
            cleanup 65
          fi
          shift
          title="$1"
          shift
        ;;
        -o|--options)
          if [[ "$#" -lt 2 ]]; then
            echo >&2 "Error - The -o|--options option needs at least one arg."
            cleanup 65
          fi
          shift
          while [[ "$#" -gt 0 && ! "$1" =~ ^--? ]]; do
            opts+=("$1")
            shift
          done
        ;;
        -m|--multiple)
          multiple=0
          shift
        ;;
        -l|--line)
          size=1
          shift
        ;;
        -h|--help)
          echo -e "$usage"
          cleanup
        ;;
        -v|--version)
          echo "$version"
          cleanup
        ;;
        *)
          echo >&2 "Error - Unknown option: $1"
          cleanup 64
        ;;
      esac
    done

    if [[ -z "${title:-}" ]]; then
      title="Choose one"
    fi

    if [[ "${#opts[@]}" -eq 0 ]]; then
      opts=(Yes No)
    fi

    if [[ "$no_cancel" -eq 1 ]]; then
      for o in "${opts[@]}"; do
        if [[ "${o,,}" == "cancel" ]]; then
          has_cancel=0
        fi
      done

      if [[ "$has_cancel" -eq 1 ]]; then
        opts+=(Cancel)
      fi
    fi

    if [[ "$multiple" -eq 1 ]]; then
      title="${title} (up|j, down|k, enter: choose)"
    else
      title="${title} (up|j, down|k, space: de/select, enter: done)"
    fi

    printf -v title "%s" "$title"

    printf >&2 "%s\n" "$title"
    hr

    while true; do
      if [[ "$size" -eq "1" ]]; then
        printf >&2 "\e[1000D\e[2K"
        print_selected "${opts[$selected]}"
      else 
        for index in $(seq 0 "$((${#opts[@]} - 1))"); do
          printf >&2 "\n"
          if [[ ("$multiple" -eq "0" && "$choices" == *",${opts[$index]},"*) || "$index" == "$selected" ]]; then
            print_selected >&2 "${opts[$((index))]}"
          else
            printf >&2 "%s" "${opts[$((index))]}"
          fi
          index="((index + 1))"
        done

        printf >&2 "\e[%sA" "${#opts[@]}"
      fi

      case $(key_input 2> /dev/null) in
        'up'|'j')
          selected=$((selected - 1))
          if [ "$selected" -lt 0 ]; then selected=$(("${#opts[@]}" - 1)); fi
        ;;
        'down'|'k')
          selected=$(("$selected" + 1))
          if [ "$selected" -gt $(("${#opts[@]}" - 1)) ]; then selected=0; fi
        ;;
        'space')
          if [[ "$multiple" -eq 0 ]]; then
            if [[ "$choices" == *",${opts[$selected]},"* ]]; then
              choices="${choices/,${opts[$selected]},/,}"
            else
              choices="${choices}${opts[selected]},"
            fi
          fi
        ;;
        'enter')
          printf >&2 "\e[%sB\n" "${#opts[@]}"
          hr

          if [[ "$multiple" -ne 0 ]]; then
            printf "%s\n" "${opts[$selected]}"
          else
            IFS=',' read -ra choice_array <<< "${choices#,}"

            if [[ "${#choice_array[@]}" -eq 0 ]]; then
              read -rsn 1 -p "Make a choice (press any key to continue)" >&2
              printf >&2 "\e[1000D\e[1A\e[J\e[%sA" "$((${#opts[@]} + 1))"
              choices=","
              continue
            else
              printf "'%s' " "${choice_array[@]}"
              printf "\n"
            fi
          fi

          cursor_on
          exit
        ;;
      esac
    done
  }

  sind "$@"
}
