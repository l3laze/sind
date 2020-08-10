#!/usr/bin/env bash

# This script is based on code by Alexander Klimetschek at
# https://unix.stackexchange.com/a/415155/310780

#
# Follows the suggested exit code range of 0 & 64-113
# from http://www.tldp.org/LDP/abs/html/exitcodes.html
#
# | Exit Code | Meaning |
# |    ---    |   ---   |
# |     0     |  No errors. |
# |    64     |  Unknown option. |
# |    65     |  Invalid arg for option. |
# |    66     |  Abnormal exit (ctrl + c, etc) |
# |    ---    |  --- |
#

{
  key_input () {
    local key
    IFS=; read -rsN 1
    key="$REPLY"
      if [[ "$key" =~ ^[A-Za-z0-9]$ ]]; then printf "%s" "$key";
    elif [[ "$key" == $'\n' ]]; then printf "enter";
    elif [[ "$key" == $' ' ]]; then printf "space";
    elif [[ "$key" == $'\e' ]]; then
      IFS=; read -rsN 2 -t 0.01
        if [[ "$REPLY" == "[A" ]]; then printf "up";
      elif [[ "$REPLY" == "[B" ]]; then printf "down";
      fi
    fi
    key=;
  }

  cursor_on () {
    printf >&2 "\e[?25h"
  }

  cursor_off () {
    printf >&2 "\e[?25l"
  }

  hr () {
    printf -v horule '%*s' "${COLUMNS:-$(tput cols)}" ''
    printf >&2 "%s" "${horule// /-}"
  }

  print_selected () {
    printf >&2 "%s" $'\e[7m'"$1"$'\e[27m'
  }

  sind () {
    local opts
    local selected=0
    local title
    local directions
    local choices=","
    local multiple=1
    local add_cancel=1
    local index=0
    local size=0
    local sel_mark=">"
    local usage
    local version
    local name="${0#\.\/}"

    opts=()
    version="$(<VERSION)"
    name="${name%.sh}"
    usage="$name $version\n\nA semi-magical list-friendly selection dialog for Bash 4+ with reasonable defaults. Features single and multiple choice modes, and can display the option list on a single line.\n\nUsage $0 [options...]\n\nWhere options are:\n\n-c|--cancel\n     Add cancel to end of options if it doesn't exist\n-h|--help\n    Display this message\n-l|--line\n    Single-line list mode\n-m|--multiple\n    Multiple choice mode\n-o|--options = Yes No\n    Space-separated options (requires at least one arg)\n-t|--title = Choose one/some (requires one arg)\n    Prompt printed above list\n-v|--version\n    Print version\n--marker = >\n    Character used to mark selected options in multiple choice"

    cleanup () {
      printf >&2 "\e[%sB\n" "${#opts[@]}"
      [[ "$-" == *"i"* ]] && stty echo
      cursor_on
      # shellcheck disable=SC2086
      exit $1
    }

    trap "cleanup" HUP INT QUIT ABRT
    cursor_off
    [[ "$-" == *"i"* ]] && stty -echo

    while [[ "$#" -gt 0 ]]; do
      case "${1:-}" in
        -c|--cancel)
          shift
          if [[ "${opts[*],,}" != *"cancel"* ]]; then
            add_cancel=0
          fi
        ;;
        -h|--help)
          echo -en >&2 "$usage"
          cleanup 0
        ;;
        -l|--line)
          size=1
          shift
        ;;
        -m|--multiple)
          multiple=0
          shift
        ;;
        --marker)
          if [[ "$#" -lt 2 ]]; then
            printf >&2 "Error: Marker must be one character."
            cleanup 65
          fi
          shift
          sel_mark="$1"
          shift
          if [[ "${#sel_mark}" -lt 1 ]]; then
            printf >&2 "Error: Marker can't be empty."
            cleanup 65
          elif [[ "${#sel_mark}" -gt 1 ]]; then
            printf >&2 "Error: Marker can't be more than one character."
            cleanup 65
          fi
        ;;
        -o|--options)
          if [[ "$#" -lt 2 ]]; then
            printf >&2 "Error: Options must be at least one character."
            cleanup 65
          fi
          shift
          while [[ "$#" -gt 0 && ! "$1" =~ ^--? ]]; do
            if [[ "$1" == "" ]]; then
              printf >&2 "Error: Empty options are not allowed."
              cleanup 65
            fi
            opts+=("$1")
            shift
          done
        ;;
        -t|--title)
          if [[ "$#" -lt 2 ]]; then
            printf >&2 "Error: Title must be at least one character."
            cleanup 65
          fi
          shift
          title="$1"
          shift
          if [[ "${#title}" -lt 1 ]]; then
            printf >&2 "Error: Empty title is not allowed."
            cleanup 65
          fi
        ;;
        -v|--version)
          printf >&2 "%s" "$(<VERSION)"
          cleanup 0
        ;;
        *)
          printf >&2 "Error: Unknown option: %s." "$1"
          cleanup 64
        ;;
      esac
    done

    if [[ -z "${title:-}" ]]; then
      if [[ "$multiple" -eq 1 ]]; then
        title="Choose one"
      else
        title="Choose some"
      fi
    fi

    if [[ "${#opts[@]}" -eq 0 ]]; then
      opts=(Yes No)
    fi

    if [[ "$add_cancel" -eq 0 ]]; then
      opts+=(Cancel)
    fi

    if [[ "$multiple" -eq 1 ]]; then
      directions="(↑/j or ↓/|k, enter: choose)"
    else
      directions="(↑|j or ↓|k, space: de/select, enter: done)"
    fi

    if [[ "$((${#title} + ${#directions} + 1))" -lt "${COLUMNS:-$(tput cols)}" ]]; then
      echo -e >&2 "$title $directions"
    else
      echo -e >&2 "$title\n$directions"
    fi

    hr

    [[ "$size" -eq 1 ]] && printf "\n"

    while true; do
      if [[ "$size" -eq "1" ]]; then
        printf >&2 "\e[2K\e[1000D"

        if [[ ("$multiple" -eq 0 && "$choices" == *",${opts[$selected]},"*) ]]; then
          printf >&2 "%s" "$sel_mark"
        elif [[ "$multiple" -eq 0 ]]; then
          printf >&2 " "
        fi

        print_selected >&2 "${opts[$selected]}"
      else 
        for index in $(seq 0 "$((${#opts[@]} - 1))"); do
          printf >&2 "\n"

          if [[ ("$multiple" -eq "0" && "$choices" == *",${opts[$index]},"*) ]]; then
            printf >&2 "%s" "$sel_mark"
          elif [[ "$multiple" -eq 0 ]]; then
            printf >&2 " "
          fi

          if [[ "$index" == "$selected" ]]; then
            print_selected >&2 "${opts[$((index))]}"
          else
            printf "%s" "${opts[$((index))]}"
          fi

          index="((index + 1))"
        done

        printf >&2 "\e[%sA" "${#opts[@]}"
      fi

      case "$(key_input 2>/dev/null)" in # LCOV_EXCL_LINE
        'up'|'j')
          selected=$((selected - 1))

          if [ "$selected" -lt 0 ]; then selected=$(("${#opts[@]}" - 1)); fi
        ;;
        'down'|'k')
          selected=$((selected + 1))

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
          if [[ "$size" -eq 0 ]]; then
            printf >&2 "\e[%sB\n" "${#opts[@]}"
          else
            printf >&2 "\n"
          fi

          hr

          if [[ "$multiple" -ne 0 ]]; then
            printf "%s" "${opts[$selected]}"
          else
            IFS=',' read -ra choice_array <<< "${choices#,}"
            if [[ "${#choice_array[@]}" -eq 0 ]]; then
              >&2 read -rsn 1 -p "Make a choice (press any key to continue)"

              printf >&2 "\e[1000D\e[2A\e[J"

              if [[ "$size" -ne 1 ]]; then
                printf >&2 "\e[%sA" "$((${#opts[@]}))"
              fi

              continue
            else
              for ((index = 0; index < "${#choice_array[@]}"; index++)); do
                printf "\n"
                printf "%s" "${choice_array[$index]}"
              done
            fi
          fi

          cleanup 0
        ;;
      esac
    done
  }

  sind "$@"
}
