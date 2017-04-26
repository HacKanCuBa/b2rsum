#!/usr/bin/env bash

test_description='Basic tests'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Verify help' '
    "$B2RSUM" --help | grep "Print or check BLAKE2 (512-bit) checksums recursively."
'

test_expect_success 'Verify license' '
    "$B2RSUM" --license | grep "under the terms of the GNU General Public License"
'

test_expect_success 'Verify default behaviour' '
    "$B2RSUM" && "$B2RSUM" | grep "786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce  "
'

test_expect_success 'Verify invalid parameter: --invalid' '
    ! "$B2RSUM" --invalid
'

test_expect_success 'Verify parameter w/o argument: --output' '
    "$B2RSUM" --output && [[ -r BLAKE2SUMS ]]
'

test_expect_success 'Verify parameter w/right argument: --output' '
    "$B2RSUM" --output=B2SUMS && [[ -r B2SUMS ]]
'

test_expect_success 'Verify parameter w/wrong argument: --output' '
    ! "$B2RSUM" --output WRONG
'

test_expect_success 'Verify parameter w/o argument: --length' '
    ! "$B2RSUM" --length
'

test_expect_success 'Verify parameter w/right argument: --length' '
    "$B2RSUM" --length 8
'

test_expect_success 'Verify parameter w/wrong argument: --length' '
    ! "$B2RSUM" --length 7
'

test_expect_success 'Verify --quiet during creation' '
    echo | "$B2RSUM" --quiet - 2>&1 | grep "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a" && ! echo | "$B2RSUM" --quiet - 2>&1 | grep "b2rsum"
'

test_expect_success 'Verify --quiet during check' '
    echo > "$SHARNESS_TRASH_DIRECTORY/t" &&
    printf "%s" "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a  $SHARNESS_TRASH_DIRECTORY/t" | "$B2RSUM" --quiet --check - 2>&1 | wc -m | grep 0
'
test_expect_success 'Verify --status during creation' '
    echo | "$B2RSUM" --status - 2>&1 | grep "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a" && ! echo | "$B2RSUM" --status - 2>&1 | grep "b2rsum"
'
test_expect_success 'Verify --status during check' '
    echo > "$SHARNESS_TRASH_DIRECTORY/t" &&
    printf "%s" "ca6914d2e33b83f2b2c66e4e625bc1d08674fae605008a215165d3c3a997d7d92945905207a539a7327be0f2728fa9aee005da9641407e5f3e4ef55b446b470a  $SHARNESS_TRASH_DIRECTORY/t" | "$B2RSUM" --status --check - 2>&1 | wc -m | grep 0 &&
    ! printf "%s" "bad format" | "$B2RSUM" --status --strict --check - 2>&1 | wc -m | grep 0
'

test_done

