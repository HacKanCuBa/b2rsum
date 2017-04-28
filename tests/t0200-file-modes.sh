#!/usr/bin/env bash

test_description='Files tests with options'
cd "$(dirname "$0")"
. ./setup.sh

FILE="$(mktemp --tmpdir="$DIRECTORY" "$(basename "$0")-XXXX.tmp")"
printf "%s" "5mo0NIVqkY2Iwg2AfuOG/qZ8cNKLFLaIbZxoPYsMR5div4ek4zLfYNu+HBgeVeRMFR6jLJgwSFWBQy/uFl37fg==" | base64 -d > "$FILE" 

test_expect_success 'Check file operation with --binary' '
    "$B2RSUM" --binary "$FILE" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *"
'

test_expect_success 'Check file operation with --text' '
    "$B2RSUM" --text "$FILE" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  "
'

test_expect_success 'Check file operation with --check (text)' '
    printf "%s" "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE" > "${FILE}.B2SUMS" &&
    "$B2RSUM" --check "${FILE}.B2SUMS" | grep "$FILE: OK"
'

test_expect_success 'Check file operation with --check (binary)' '
    printf "%s" "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *$FILE" > "${FILE}.B2SUMS" &&
    "$B2RSUM" --check "${FILE}.B2SUMS" | grep "$FILE: OK"
'

test_expect_success 'Check file operation with --check --warn' '
    printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 &$FILE" > "${FILE}.B2SUMS" &&
    "$B2RSUM" --check --warn "${FILE}.B2SUMS" 2>&1 | grep "improperly formatted BLAKE2 checksum line"
'

test_expect_success 'Check file operation with --check --strict' '
    printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 &$FILE" > "${FILE}.B2SUMS" &&
    ! "$B2RSUM" --check --strict "${FILE}.B2SUMS"
'

test_expect_success 'Check file operation with --check --ignore-missing' '
    printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  missing" > "${FILE}.B2SUMS" &&
    "$B2RSUM" --check --ignore-missing "${FILE}.B2SUMS"
'

test_expect_success 'Check file operation with --length --text' '
    "$B2RSUM" --text --length 16 "$FILE" | grep "7ee7  "
'

test_expect_success 'Check file operation with --length --binary' '
    "$B2RSUM" --text --length 16 "$FILE" | grep "7ee7 *"
'

test_expect_success 'Check file operation with --tag' '
    "$B2RSUM" --tag "$FILE" | grep "BLAKE2b (${FILE}) = 7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276"
'

test_expect_success 'Check file operation with --output --text' '
    "$B2RSUM" --output --text "$FILE" &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  " "BLAKE2SUMS"
'

test_expect_success 'Check file operation with --output --binary' '
    "$B2RSUM" --output --binary "$FILE" &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  *" "BLAKE2SUMS"
'

test_done

