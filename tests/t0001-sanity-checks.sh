#!/usr/bin/env bash

test_description='Sanity checks'
cd "$(dirname "$0")"
. ./setup.sh

VERSION_MAJOR=0
VERSION_MINNOR=1
VERSION_REV=1

test_expect_success 'Make sure we can run b3rsum' '
    "$B3RSUM" --help | grep "Print or check BLAKE2 (512-bit) checksums recursively"
'

test_expect_success 'Check version' '
    IFS="." read -r -a version <<< "$("$B3RSUM" --version | cut -d" " -f2 | cut -d"v" -f2)" &&
    [[ ${version[0]} -ge $VERSION_MAJOR ]] && [[ ${version[1]} -ge $VERSION_MINOR ]] && [[ ${version[2]} -ge $VERSION_REV ]]
' 

test_done
