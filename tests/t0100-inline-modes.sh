#!/usr/bin/env bash

test_description='Inline tests with options'
cd "$(dirname "$0")"
. ./setup.sh

RANDOM_VALUE='5mo0NIVqkY2Iwg2AfuOG/qZ8cNKLFLaIbZxoPYsMR5div4ek4zLfYNu+HBgeVeRMFR6jLJgwSFWBQy/uFl37fg=='
FILE="$(mktemp --tmpdir="$DIRECTORY" "$(basename "$0")-XXXX.tmp")"
printf "%s" "$RANDOM_VALUE" | base64 -d > "$FILE" 

test_expect_success 'Check inline operation with --binary' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --binary - | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *"
'

test_expect_success 'Check inline operation with --text' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --text - | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  "
'

test_expect_success 'Check inline operation with --check (text)' '
    printf "%s" "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE" | "$B3RSUM" --check - | grep "$FILE: OK"
'

test_expect_success 'Check inline operation with --check (binary)' '
    printf "%s" "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *$FILE" | "$B3RSUM" --check - | grep "$FILE: OK"
'

test_expect_success 'Check inline operation with --check --warn' '
    printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 &$FILE" | "$B3RSUM" --check --warn - 2>&1 | grep "improperly formatted BLAKE2 checksum line"
'

test_expect_success 'Check inline operation with --check --strict' '
    ! printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 &$FILE" | "$B3RSUM" --check --strict -
'

test_expect_success 'Check inline operation with --check --ignore-missing' '
    printf "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  $FILE\n7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  missing" | "$B3RSUM" --check --ignore-missing -
'

test_expect_success 'Check inline operation with --length --text' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --text --length 16 - | grep "7ee7  "
'

test_expect_success 'Check inline operation with --length --binary' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --binary --length 16 - | grep "7ee7 *"
'

test_expect_success 'Check inline operation with --tag' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --tag - | grep "BLAKE2b (-) = 7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276"
'

test_expect_success 'Check inline operation with --output --text' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --output --text - &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  " "BLAKE2SUMS"
'

test_expect_success 'Check inline operation with --output --binary' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" --output --binary - &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *" "BLAKE2SUMS"
'

test_done

