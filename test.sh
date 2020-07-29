#!/usr/bin/env bash

if command -v "shellcheck" > /dev/null 2>&1; then
  echo "shellcheck"
  shellcheck sind.sh && printf "  ✓ sind.sh\n" || exit 64
  shellcheck install.sh && printf "  ✓ install.sh\n" || exit 64
  shellcheck test.sh && printf "  ✓ test.sh\n" || exit 64
else
  echo "Need shellcheck installed for linting."
fi

run () {
  local timer="$(date +%s%3N)"
  local label
  local actual
  local expected
  local passed=0
  local total=0

  test () {
    label="$1"
    actual=$(tr -dc '[:print:]' <<< "$2")
    actual="${actual//\[\?25l/}"
    actual="${actual//\[\?25h/}"
    expected="$3"
  
    total=$((total + 1))

    if [[ "$actual" == *"$expected"* ]]; then
      printf "  ✓ %s\n" "$label"
      passed=$((passed + 1))
    else
      printf "  × %s\n'%s' != '%s'\n" "$label" "$expected" "$actual"
    fi
  }


  echo "sind/sind.sh"

  # SHOULD PASS
  test "Prints usage" "$(./sind.sh -h 2>/dev/null)" "USAGE"

  test "Takes a title" "$(./sind.sh -t t <<< $'\n' 2>/dev/null)" "Yes"

  test "Takes an option" "$(./sind.sh -t t -o Okay <<< $'\n' 2>/dev/null)" "Okay"

  test "Uses default title" "$(./sind.sh 2>&1 <<< $'\n')" "Choose one"

  [[ "${TRAVIS:-false}" != "true" ]] && { test "Handles here-string input" "$(./sind.sh -t t <<< $'\e[A\n' 2>/dev/null)" "Cancel"; }


  # SHOULD FAIL
  set +e

  test "Fails with invalid options" "$(./sind.sh -x 2>&1)" "Error - Unknown option - -x"

  test "Fails with -t|--title and no arg" "$(./sind.sh 2>&1 -t)" "Error - The -t|--title option needs an arg."

  test "Fails with -o|--options and no args" "$(./sind.sh 2>&1 -o)" "Error - The -o|--options option needs at least one arg."

  set -e


  echo "sind/install.sh"

  # SHOULD PASS
  if [[ "${TRAVIS:-false}" != "true" ]]; then
    test "Installs from GitHub" "$(./install.sh -t 2>&1)" "Installation from GitHub was successful!"

    test "Installs from local copy" "$(./install.sh -l -t 2>&1)" "Installation from local copy was successful!"
  else
    test "Installs from GitHub" "$(sudo ./install.sh -t 2>&1)" "Installation from GitHub was successful!"

    test "Installs from local copy" "$(sudo ./install.sh -l -t 2>&1)" "Installation from local copy was successful!"
  fi

  # SHOULD FAIL
  test "Fails with invalid option" "$(./install.sh -x 2>&1)" "Error - unknown option -x"


  echo -e "\n$passed/$total passed"

  timer="$(($(date +%s%3N) - $timer))"

  printf "Finished in %s.%s seconds\n" "$((timer / 1000))" "$((timer % 1000))"

  if [[ "$passed" -lt "$total" ]]; then
    exit 64
  fi
}

run
