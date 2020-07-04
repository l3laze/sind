#!/usr/bin/env bash

run () {
  local timer="$SECONDS"
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

    if [[ "$actual" =~ $expected ]]; then
      printf "  ✓ %s\n" "$label"
      passed=$((passed + 1))
    else
      printf "  × %s\n'%s' != '%s'\n" "$label" "$expected" "$actual"
    fi
  }


  echo "sind/sind.sh"

  # SHOULD PASS
  test "Takes a title" "$(./sind.sh -t t <<< $'\n' 2>/dev/null)" "Yes"

  test "Takes an option" "$(./sind.sh -t t -o Okay <<< $'\n' 2>/dev/null)" "Okay"

  if [[ "$TRAVIS" != "true" ]]; then
    test "Handles here-string input" "$(./sind.sh -t t <<< $'\e[B\n' 2>/dev/null)" "No"
  fi


  # SHOULD FAIL
  set +e

  test "Fails with no title specified" "$(./sind.sh -o Okay 2>&1)" "Error - No title specified."

  test "Fails with no args" "$(./sind.sh 2>&1)" "Error - Specify a title with -t or --title."

  test "Fails with -t|--title and no args" "$(./sind.sh 2>&1 -t)" "Error - The -t|--title option needs an arg."

  test "Fails with -o|--options and no args" "$(./sind.sh 2>&1 -o)" "Error - The -o|--options option needs at least one arg."

  test "Fails with invalid option" "$(./sind.sh -x 2>&1)" "Error - Unknown option - -x"

  set -e


  echo "sind/install.sh"

  # SHOULD PASS
  test "Installs from GitHub" "$(sudo ./install.sh -t 2>&1)" "Installation from GitHub was successful!"

  test "Installs from local copy" "$(sudo ./install.sh -l -t 2>&1)" "Installation from local copy was successful!"

  # SHOULD FAIL
  test "Fails with invalid option" "$(./install.sh -x 2>&1)" "Error - unknown option -x"


  echo -e "\n$passed/$total passed"
  timer="$((SECONDS - timer))"

  printf "Finished in < %0.f seconds\n" "$((timer + 1))"

  if [[ "$passed" -lt "$total" ]]; then
    exit 64
  fi
}

run
