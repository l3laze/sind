#!/usr/bin/env bash

fail () {
  echo -e >&2 "$1"
  # shellcheck disable=SC2086
  exit $2
}

run () {
  local timer

  timer="$(date +%s%3N)"

  echo -e "#\n# ******** PASSING TESTS ********\n#"

  printf "\n ===> %s <===\n" "Installs latest release automatically from GitHub"
  ./install.sh 2>&1 || fail "Did not auto install"

  printf "\n ===> %s <===\n" "Prints usage" 
  ./sind.sh -h 2>&1 || fail "Did not print usage"

  printf "\n ===> %s <===\n" "Prints version"
  ./sind.sh -v 2>&1 || fail "Did not print version"

  printf "\n ===> %s <===\n" "Uses defaults"
  ./sind.sh <<< $'\n' 2>&1 || fail "Did not use defaults"

  printf "\n ===> %s <===\n" "Takes a title arg"
  ./sind.sh -t "title goes here" <<< $'\n' 2>&1 || fail "Did not handle title arg"

  printf "\n ===> %s <===\n" "Takes an option arg"
  ./sind.sh -o Okay <<< $'\n' || fail "Did not handle option arg"

  printf "\n ===> %s <===\n" "Takes here-string input"
  ./sind.sh <<< $'\e[2A\n' || fail "Did not handle here-string input"

  printf "\n ===> %s <===\n" "Multiple-choice"
  ./sind.sh -m <<< $' \e[B\n \n' || fail "Did not handle multiple-choice"

  printf "\n ===> %s <===\n" "Press any key to continue"
  ./sind.sh -m <<< $'\n \e[A \n' || fail "Did not handle press any key to continue"

  printf "\n ===> %s <===\n" "Removes de-selected choices"
  ./sind.sh -m <<< $'  \e[B \n' || fail "Did not remove de-selected choices"

  printf "\n ===> %s <===\n" "Line mode"
  ./sind.sh -l <<< $'\e[B\n' || fail "Did not handle line mode"

  printf "\n ===> %s <===\n" "Combo multiple-choice + line mode"
  ./sind.sh -l -m <<< $' \e[B \n' || fail "Did not handle combo multiple-choice + line mode"

  printf "\n ===> %s <===\n" "Adds cancel"
  ./sind.sh -c <<< $'\e[A\n' || fail "Did not handle adding cancel"

  printf "\n ===> %s <===\n" "Custom selection marker"
  ./sind.sh -m --marker + <<< $' \e[B\n' || fail "Did not handle selection marker replacement"

  printf "\n ===> %s <===\n" "Splits title from directions"
  ./sind.sh -t 'This should be a sufficiently long title to cause it to have a newline between itself and the directions' <<< $'\n' 2>&1 || fail "Did not handle splitting title and directions"

  #
  # FAILURES
  #

  echo -e "\n#\n# ******** FAILING TESTS ********\n#"

  head -1 <<< "$(./sind.sh -x 2>&1 && fail 'Did not fail with invalid option')"
  ./sind.sh -t 2>&1 && fail "Did not fail with -t and no arg"
  ./sind.sh -t '' 2>&1 && fail "Did not fail with -t and empty arg"
  ./sind.sh -o 2>&1 && fail "Did not fail with -o and no args"
  ./sind.sh -o '' 2>&1 && fail "Did not fail with -o and empty arg"
  ./sind.sh --marker 2>&1 && fail "Did not fail with --marker and no arg"
  ./sind.sh --marker 69 2>&1 && fail "Did not fail with --marker and 2+ character arg"
  ./sind.sh --marker '' 2>&1 && fail "Did not fail with --marker and empty arg"

  timer="$(($(date +%s%3N) - timer))"

  printf "Finished in %s.%s seconds\n" "$((timer / 1000))" "$((timer % 1000))"
}

run