#!/usr/bin/env bash

test_description='Basic tests'
cd "$(dirname "$0")"
. ./setup.sh

RANDOM_VALUE='5mo0NIVqkY2Iwg2AfuOG/qZ8cNKLFLaIbZxoPYsMR5div4ek4zLfYNu+HBgeVeRMFR6jLJgwSFWBQy/uFl37fg=='
DIRECTORY="$SHARNESS_TRASH_DIRECTORY/dir"
mkdir -p "$DIRECTORY"
FILE="$(mktemp --tmpdir="$DIRECTORY" "$(basename "$0")-XXXX.tmp")"
printf "%s" "$RANDOM_VALUE" | base64 -d > "$FILE" 

test_expect_success 'Check inline operation' '
    printf "%s" "$RANDOM_VALUE" | base64 -d | "$B3RSUM" - | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276"
'
test_expect_success 'Check file operation' '
    "$B3RSUM" "$FILE" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276"
'
test_expect_success 'Check directory operation' '
    "$B3RSUM" "$DIRECTORY" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276"
'

test_done

