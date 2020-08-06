#!/usr/bin/env bash

if command -v "shellcheck" > /dev/null 2>&1; then
  echo "shellcheck"
  shellcheck ./*.sh && printf "  ✓ sind.sh\n  ✓ install.sh\n  ✓ test.sh\n" || exit 64
else
  echo >&2 "Need shellcheck installed for linting." # LCOV_EXCL_LINE
fi

run () {
  local timer
  local label
  local actual
  local expected
  local passed=0
  local total=0

  timer="$(date +%s%3N)"

  test () {
    label="$1"
    actual="$2" #{2//(\x1b[[a-Z0-9;]+)/}"
    expected="$3"
    ((total++))

    if [[ "$actual" == *"$expected"* ]]; then
      printf "  ✓ %s\n" "$label"
      ((passed++))
    else
      printf "  × %s\n%s != %s\n" "$label" "$expected" "$actual" # LCOV_EXCL_LINE
    fi
  }

  echo "install.sh"

  test "Installs latest release automatically from GitHub" "$(./install.sh 2>&1)" "Success"

  echo "sind.sh"

  # SHOULD PASS
  test "Prints usage" "$(./sind.sh -h 2>&1)" "Usage"

  test "Prints version" "$(./sind.sh -v 2>&1)" "$(<VERSION)"

  test "Uses default title" "$(./sind.sh <<< $'\n' 2>&1)" "Choose one"

  test "Takes a title" "$(./sind.sh -t "title goes here" <<< $'\n' 2>&1)" "title goes here"

  test "Takes an option" "$(./sind.sh -o Okay <<< $'\n' 2>/dev/null)" "Okay"

  test "Handles here-string input" "$(./sind.sh <<< $'\e[2A\n' 2>/dev/null)" "Yes"

  test "Multiple choice" "$(./sind.sh -m <<< $' \e[B ' 2>/dev/null)" $'Yes\nNo'

  test "Press any key to continue" "$(./sind.sh -m <<< $'\n \e[B \n' 2>/dev/null)" "No"

  test "Removes de-selected choices" "$(./sind.sh -m <<< $'  \e[B \n' 2>/dev/null)" "No"

  test "Line mode" "$(./sind.sh -l <<< $'\e[B\n' 2>/dev/null)" "No"

  test "Combo line mode + multiple choice" "$(./sind.sh -l -m <<< $' \e[B \n' 2>/dev/null)" $'Yes\nNo'

  test "Arg -c adds cancel if not provided" "$(./sind.sh -c <<< $'\e[A\n' 2>/dev/null)" "Cancel"

  test "Arg -y changes selection symbol" "$(./sind.sh -m -y • <<< $' \e[B\n' 2>&1)" "•Yes"

  # SHOULD FAIL
  test "Fails with invalid options" "$(./sind.sh -x 2>&1)" "Error - Unknown option: -x"

  test "Fails with -t|--title and no arg" "$(./sind.sh -t 2>&1)" "Error - The -t|--title option needs an arg."

  test "Fails with -o|--options and no args" "$(./sind.sh -o 2>&1)" "Error - The -o|--options option needs at least one arg."

  echo -e "\n$passed/$total passed"

  timer="$(($(date +%s%3N) - timer))"

  printf "Finished in %s.%s seconds\n" "$((timer / 1000))" "$((timer % 1000))"

  if [[ "$passed" -lt "$total" ]]; then
    exit 64 # LCOV_EXCL_LINE
  fi
}

run
