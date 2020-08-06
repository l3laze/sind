#!/usr/bin/env bash

# This script is based on code by Alexander Klimetschek at
# https://unix.stackexchange.com/a/415155/310780

{
  #
  # Follows the suggested exit code range of 0 & 64-113
  # from http://www.tldp.org/LDP/abs/html/exitcodes.html
  #
  # | Exit Code | Meaning |
  # |    ---    |   ---   |
  # |     0     |  No errors. |
  # |    64     |  Unknown option. |
  # |    65     |  Invalid arg for option |
  # |    ---    |  --- |
  #
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
    local choices=","
    local multiple=1
    local add_cancel=1
    local index=0
    local size=0
    local sel_sym=">"
    local usage
    local version
    local name="${0#\.\/}"
    opts=()
    version="$(<VERSION)"
    name="${name%.sh}"
    usage="$name v$version\n\nA semi-magical list-based selection dialog for Bash 4+ with reasonable defaults. Features single and multiple choice modes, and can display the option list on a single line.\n\nUsage $0 [options...]\n\nWhere options are:\n\n-c|--cancel\n    Add cancel to end of options, if not provided.\n-h|--help\n    Display this message.\n-l|--line\n    Single-line list mode.\n-m|--multiple\n    Multiple choice mode.\n-o|--options = Yes No\n    Space-separated options (requires at least one arg).\n-t|--title = Choose one/some (requires one arg).\n    Choice prompt printed above list.\n-v|--version\n    Print version.\n-y|--selected-symbol = >\n    Character used to mark selected options in multiple choice."

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
        -c|--cancel)
          shift
          if [[ "${opts[*],,}" != *"cancel"* ]]; then
            add_cancel=0
          fi
        ;;
        -h|--help)
          echo -e >&2 "$usage\n"
          cursor_on
          exit
        ;;
        -l|--line)
          size=1
          shift
        ;;
        -m|--multiple)
          multiple=0
          shift
        ;;
        -o|--options)
          if [[ "$#" -lt 2 ]]; then
            echo >&2 "Error: The -o|--options option needs at least one arg."
            cleanup 65
          fi
          shift
          while [[ "$#" -gt 0 && ! "$1" =~ ^--? ]]; do
            opts+=("$1")
            shift
          done
        ;;
        -t|--title)
          if [[ "$#" -lt 2 ]]; then
            echo >&2 "Error: The -t|--title option needs an arg."
            cleanup 65
          fi
          shift
          title="$1"
          shift
          if [[ "${#title}" -lt 1 ]]; then
            echo >&2 "Error: The -t|--title option needs an arg of at least one character."
            cleanup 65
          fi
        ;;
        -v|--version)
          cat VERSION >&2 && printf >&2 "\n"
          cursor_on
          exit
        ;;
        -y|--selected-symbol)
          if [[ "$#" -lt 2 ]]; then
            echo >&2 "Error: The -y|--selected-symbol option needs a one-character arg."
            cleanup 65
          fi
          shift
          sel_sym="$1"
          shift
          if [[ "${#sel_sym}" -ne 1 ]]; then
            echo >&2 "Error: The arg to -y|--selected-symbol must be only one character."
            cleanup 65
          fi
        ;;
        *)
          echo -e >&2 "Error: Unknown option: $1\n\n$usage\n"
          cursor_on
          exit
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
      printf >&2 "%s\n(↑/j or ↓/|k, enter: choose)\n" "$title"
    else
      printf >&2 "%s\n(↑/j or ↓/|k, space: de/select, enter: done)\n" "$title"
    fi

    hr

    while true; do
      if [[ "$size" -eq "1" ]]; then
        printf >&2 "\e[1000D\e[2K"

        if [[ ("$multiple" -eq 0 && "$choices" == *",${opts[$selected]},"*) ]]; then
          printf >&2 "%s" "$sel_sym"
        elif [[ "$multiple" -eq 0 ]]; then
          printf >&2 " "
        fi

        print_selected >&2 "${opts[$selected]}"
      else 
        for index in $(seq 0 "$((${#opts[@]} - 1))"); do
          printf >&2 "\n"

          if [[ ("$multiple" -eq "0" && "$choices" == *",${opts[$index]},"*) ]]; then
            printf >&2 "%s" "$sel_sym"
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

      case $(key_input 2>/dev/null) in
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
            printf "%s\n" "${opts[$selected]}"
          else
            IFS=',' read -ra choice_array <<< "${choices#,}"
            if [[ "${#choice_array[@]}" -eq 0 ]]; then
              >&2 read -rsn 1 -p "Make a choice (press any key to continue)"

              if [[ "$size" -eq 0 ]]; then
                printf >&2 "\e[1000D\e[1A\e[J\e[%sA" "$((${#opts[@]} + 1))"
              fi

              choices=","
              continue
            else
              printf "%s\n" "${choice_array[@]}"
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
