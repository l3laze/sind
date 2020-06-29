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

    if [[ "$expected" == "$actual" ]]; then
      printf "✓ %s\n" "$label"
      passed=$((passed + 1))
    else
      printf "× %s\n" "$label"
    fi
  }



  #
  # SHOULD PASS
  #
  test "Takes a title" "$(./sind.sh -t t <<< $'\n' 2>/dev/null)" "Yes"

  test "Takes an option" "$(./sind.sh -t t -o Okay <<< $'\n' 2>/dev/null)" "Okay"



  #
  # SHOULD FAIL
  #
  set +e

  test "Fails with no title specified" "$(./sind.sh -o Okay 2>&1)" "Error - No title specified."

  test "Fails with no args" "$(./sind.sh 2>&1)" "Error - Specify a title with -t or --title."

  test "Fails with -t|--title and no args" "$(./sind.sh 2>&1 -t)" "Error - The -t|--title option needs an arg."

  test "Fails with -o|--options and no args" "$(./sind.sh 2>&1 -o)" "Error - The -o|--options option needs at least one arg."

  set -e


  echo -e "\n$passed/$total passed"
  timer="$((SECONDS - timer))"

  if [[ "$timer" -lt 1 ]]; then timer=$((timer + 1)); fi

  printf "Finished in %0.f+ second(s)\n" "$timer"
}

run "$@"
