#!/usr/bin/env bash

if command -v "shellcheck" > /dev/null 2>&1; then
  echo "shellcheck"
  shellcheck sind.sh && printf "  ✓ sind.sh\n" || exit 64
  shellcheck install.sh && printf "  ✓ install.sh\n" || exit 64
  shellcheck test.sh && printf "  ✓ test.sh\n" || exit 64
else
  echo "Need shellcheck installed for linting." # LCOV_EXCL_LINE
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
    actual="${2//(\x1b[[a-Z0-9;]+)/}"
    expected="$3"
    total=$((total + 1))

    # debugging
    #echo "$actual"

    if [[ "$actual" == *"$expected"* ]]; then
      printf "  ✓ %s\n" "$label"
      ((passed++))
    else
      printf "  × %s\n%s != %s\n" "$label" "$actual" "$expected" # LCOV_EXCL_LINE
    fi
  }

  echo "sind/sind.sh"

  # SHOULD PASS
  test "Prints usage" "$(./sind.sh -h 2>/dev/null)" "Usage"

  test "Prints version" "$(./sind.sh -v 2>/dev/null)" "5.0.0b"

  test "Uses default title" "$(./sind.sh 2>&1 <<< $'\n')" "Choose one"

  test "Takes a title" "$(./sind.sh -t "title goes here" <<< $'\n' 2>&1)" "title goes here"

  test "Takes an option" "$(./sind.sh -o Okay <<< $'\n' 2>/dev/null)" "Okay"

  # LCOV_EXCL_START
  if [[ "${TRAVIS:-false}" != "true" ]]; then
    test "Handles here-string input" "$(./sind.sh <<< $'\e[A\n' 2>/dev/null)" "Cancel"

    test "Multiple choice" "$(./sind.sh -m 2>/dev/null <<< $' \e[B ')" $'Yes\nNo'

    test "Press any key to continue" "$(./sind.sh -m 2>&1 <<< $'\n \e[B \n')" "No"

    test "Removes de-selected choices" "$(./sind.sh -m 2>&1 <<< $'  \e[B \n')" "No"

    test "Line mode" "$(./sind.sh -l 2>/dev/null <<< $'\e[B\n')" "No"

    test "Line mode + multiple choice" "$(./sind.sh -l -m 2>/dev/null <<< $' \e[B \n')" $'Yes\nNo'

    test "Adds cancel if not provided" "$(./sind.sh 2>/dev/null <<< $'\e[A\n')" "Cancel"

    test "Doesn't add cancel if provided" "$(./sind.sh -o okay cancel 2>&1 <<< $'\e[A\n')" "cancel"

    test "Doesn't require cancel" "$(./sind.sh -n 2>/dev/null <<< $'\e[A\n')" "No"
  fi
  # LCOV_EXCL_END

  # SHOULD FAIL
  set +e

  test "Fails with invalid options" "$(./sind.sh -x 2>&1)" "Error - Unknown option: -x"

  test "Fails with -t|--title and no arg" "$(./sind.sh -t 2>&1)" "Error - The -t|--title option needs an arg."

  test "Fails with -o|--options and no args" "$(./sind.sh -o 2>&1)" "Error - The -o|--options option needs at least one arg."

  set -e

  echo "sind/install.sh"

  # SHOULD PASS
  # LCOV_EXCL_START
  if [[ "${TRAVIS:-false}" != "true" ]]; then
    test "Installs locally from GitHub" "$(./install.sh -t 2>&1)" "Installation from GitHub was successful!"

    test "Installs locally from local copy" "$(./install.sh -l -t 2>&1)" "Installation from local copy was successful!"

    test "Installs globally from local copy" "$(./install.sh -l -s -t 2>&1)" "Installation from local copy was successful!"
    # LCOV_EXCL_END
  else
    test "Installs locally from GitHub" "$(sudo ./install.sh -t 2>&1)" "Installation from GitHub was successful!"

    test "Installs locally from local copy" "$(sudo ./install.sh -l -t 2>&1)" "Installation from local copy was successful!"

    test "Installs globally from local copy" "$(sudo ./install.sh -l -s -t 2>&1)" "Installation from local copy was successful!"
  fi

  # SHOULD FAIL
  test "Fails with invalid option" "$(./install.sh -x 2>&1)" "Error - unknown option: -x"

  echo -e "\n$passed/$total passed"

  timer="$(($(date +%s%3N) - timer))"

  printf "Finished in %s.%s seconds\n" "$((timer / 1000))" "$((timer % 1000))"

  if [[ "$passed" -lt "$total" ]]; then
    exit 64
  fi
}

run
