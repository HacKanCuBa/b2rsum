# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $B3RSUM     Full path to b3rsum script to test
#   $TEST_HOME	This folder

# We must be called from tests/ !!
TEST_HOME="$(pwd)"

. ./sharness.sh

B3RSUM="$TEST_HOME/../src/b3rsum.bash"
if [[ ! -e "$B3RSUM" ]]; then
	echo "Could not find b3rsum.bash"
	exit 1
fi
