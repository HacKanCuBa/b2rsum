#!/usr/bin/env bash

test_description='Basic tests'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Verify help' '
    "$B3RSUM" --help | grep "Print or check BLAKE2 (512-bit) checksums recursively."
'

test_expect_success 'Verify license' '
    "$B3RSUM" --license | grep "under the terms of the GNU General Public License"
'

test_expect_success 'Verify default behaviour' '
    "$B3RSUM" && "$B3RSUM" | grep "786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce  "
'

test_expect_success 'Verify invalid parameter: --invalid' '
    ! "$B3RSUM" --invalid
'

test_expect_success 'Verify parameter w/o argument: --output' '
    "$B3RSUM" --output && [[ -r BLAKE2SUMS ]]
'

test_expect_success 'Verify parameter w/right argument: --output' '
    "$B3RSUM" --output=B3SUMS && [[ -r B3SUMS ]]
'

test_expect_success 'Verify parameter w/wrong argument: --output' '
    ! "$B3RSUM" --output WRONG
'

test_expect_success 'Verify parameter w/o argument: --length' '
    ! "$B3RSUM" --length
'

test_expect_success 'Verify parameter w/right argument: --length' '
    "$B3RSUM" --length 8
'

test_expect_success 'Verify parameter w/wrong argument: --length' '
    ! "$B3RSUM" --length 7
'

test_expect_success 'Verify --quiet during creation' '
    echo | "$B3RSUM" --quiet - 2>&1 | grep "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a" && ! echo | "$B3RSUM" --quiet - 2>&1 | grep "b3rsum"
'

test_expect_success 'Verify --quiet during check' '
    echo > "$SHARNESS_TRASH_DIRECTORY/t" &&
    printf "%s" "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a  $SHARNESS_TRASH_DIRECTORY/t" | "$B3RSUM" --quiet --check - 2>&1 | wc -m | grep 0
'
test_expect_success 'Verify --status during creation' '
    echo | "$B3RSUM" --status - 2>&1 | grep "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a" && ! echo | "$B3RSUM" --status - 2>&1 | grep "b3rsum"
'
test_expect_success 'Verify --status during check' '
    echo > "$SHARNESS_TRASH_DIRECTORY/t" &&
    printf "%s" "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a  $SHARNESS_TRASH_DIRECTORY/t" | "$B3RSUM" --status --check - 2>&1 | wc -m | grep 0 &&
    ! printf "%s" "bad format" | "$B3RSUM" --status --strict --check - 2>&1 | wc -m | grep 0
'

test_done

