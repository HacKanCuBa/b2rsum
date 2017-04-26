# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $B2RSUM     Full path to b2rsum script to test
#   $TEST_HOME	This folder

# We must be called from tests/ !!
TEST_HOME="$(pwd)"

. ./sharness.sh

B2RSUM="$TEST_HOME/../src/b2rsum.bash"
if [[ ! -e "$B2RSUM" ]]; then
	echo "Could not find b2rsum.bash"
	exit 1
fi
