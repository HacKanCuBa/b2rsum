#!/usr/bin/env bash

test_description='Directories tests with options'
cd "$(dirname "$0")"
. ./setup.sh

DIRECTORY="$SHARNESS_TRASH_DIRECTORY/dir"
mkdir -p "$DIRECTORY"
FILE1="$(mktemp --tmpdir="$DIRECTORY" "$(basename "$0")-XXXX.tmp")"
FILE2="$(mktemp --tmpdir="$DIRECTORY" "$(basename "$0")-XXXX.tmp")"
printf "%s" "5mo0NIVqkY2Iwg2AfuOG/qZ8cNKLFLaIbZxoPYsMR5div4ek4zLfYNu+HBgeVeRMFR6jLJgwSFWBQy/uFl37fg==" | base64 -d > "$FILE1"
printf "%s" "Zv8gQKaTEIFRZcCpFZtii0zSMMoNPgJdv7eSUmAT4d7uecQflbersChnaqvwoaRxIvMu8dN9WQpFmGJe67gjBg==" | base64 -d > "$FILE2"


test_expect_success 'Check directory operation with --binary' '
    "$B3RSUM" --binary "$DIRECTORY" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276 *" &&
    "$B3RSUM" --binary "$DIRECTORY" | grep "8fda8c551c3f83bcc325a933ab39f6db5b2954adbe2d99ec1c471e11aa55675ffc21a1848ae56b8f82cb7dddece544acc5a7aae202d831e80a69677825307712 *"
'

test_expect_success 'Check directory operation with --text' '
    "$B3RSUM" --text "$DIRECTORY" | grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  " &&
    "$B3RSUM" --text "$DIRECTORY" | grep "8fda8c551c3f83bcc325a933ab39f6db5b2954adbe2d99ec1c471e11aa55675ffc21a1848ae56b8f82cb7dddece544acc5a7aae202d831e80a69677825307712  "
'

test_expect_success 'Check directory operation with --length --text' '
    "$B3RSUM" --text --length 16 "$DIRECTORY" | grep "7ee7  " &&
    "$B3RSUM" --text --length 16 "$DIRECTORY" | grep "544b  "
'

test_expect_success 'Check directory operation with --length --binary' '
    "$B3RSUM" --text --length 16 "$DIRECTORY" | grep "7ee7 *" &&
    "$B3RSUM" --text --length 16 "$DIRECTORY" | grep "544b *"
'

test_expect_success 'Check directory operation with --tag' '
    "$B3RSUM" --tag "$DIRECTORY" | grep "BLAKE2b (${FILE1}) = 7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276" &&
    "$B3RSUM" --tag "$DIRECTORY" | grep "BLAKE2b (${FILE2}) = 8fda8c551c3f83bcc325a933ab39f6db5b2954adbe2d99ec1c471e11aa55675ffc21a1848ae56b8f82cb7dddece544acc5a7aae202d831e80a69677825307712"
'

test_expect_success 'Check directory operation with --output --text' '
    "$B3RSUM" --output --text "$DIRECTORY" &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  " "BLAKE2SUMS" &&
    grep "8fda8c551c3f83bcc325a933ab39f6db5b2954adbe2d99ec1c471e11aa55675ffc21a1848ae56b8f82cb7dddece544acc5a7aae202d831e80a69677825307712  " "BLAKE2SUMS"
'

test_expect_success 'Check directory operation with --output --binary' '
    "$B3RSUM" --output --binary "$DIRECTORY" &&
    grep "7789e6741c4f518e45fe75608ac95377b33c6e656d4930bcf806466c0d7173ba426351081ce6d937a81d075d38e87f1828279aa9eb020461c00341c72cfab276  *" "BLAKE2SUMS" &&
    grep "8fda8c551c3f83bcc325a933ab39f6db5b2954adbe2d99ec1c471e11aa55675ffc21a1848ae56b8f82cb7dddece544acc5a7aae202d831e80a69677825307712  *" "BLAKE2SUMS"
'

test_done

