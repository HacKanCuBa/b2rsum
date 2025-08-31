#!/usr/bin/env bash

test_description='B3SUM Test Vectors from https://github.com/openssl/openssl/blob/2d0b44126763f989a4cbffbffe9d0c7518158bb7/test/evptests.txt'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success "Test Vector #1" "
    printf '%s' '' | '$B3RSUM' - | grep '786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce'
"

test_expect_success "Test Vector #2" "
    printf '%s' 'YQ==' | base64 -d | '$B3RSUM' - | grep '333fcb4ee1aa7c115355ec66ceac917c8bfd815bf7587d325aec1864edd24e34d5abe2c6b1b5ee3face62fed78dbef802f2a85cb91d455a8f5249d330853cb3c'
"

test_expect_success "Test Vector #3" "
    printf '%s' 'YWJj' | base64 -d | '$B3RSUM' - | grep 'ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923'
"

test_expect_success "Test Vector #4" "
    printf '%s' 'bWVzc2FnZSBkaWdlc3Q=' | base64 -d | '$B3RSUM' - | grep '3c26ce487b1c0f062363afa3c675ebdbf5f4ef9bdc022cfbef91e3111cdc283840d8331fc30a8a0906cff4bcdbcd230c61aaec60fdfad457ed96b709a382359a'
"

test_expect_success "Test Vector #5" "
    printf '%s' 'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=' | base64 -d | '$B3RSUM' - | grep 'c68ede143e416eb7b4aaae0d8e48e55dd529eafed10b1df1a61416953a2b0a5666c761e7d412e6709e31ffe221b7a7a73908cb95a4d120b8b090a87d1fbedb4c'
"

test_expect_success "Test Vector #6" "
    printf '%s' 'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk=' | base64 -d | '$B3RSUM' - | grep '99964802e5c25e703722905d3fb80046b6bca698ca9e2cc7e49b4fe1fa087c2edf0312dfbb275cf250a1e542fd5dc2edd313f9c491127c2e8c0c9b24168e2d50'
"

test_expect_success "Test Vector #7" "
    printf '%s' 'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTA=' | base64 -d | '$B3RSUM' - | grep '686f41ec5afff6e87e1f076f542aa466466ff5fbde162c48481ba48a748d842799f5b30f5b67fc684771b33b994206d05cc310f31914edd7b97e41860d77d282'
"

test_done
