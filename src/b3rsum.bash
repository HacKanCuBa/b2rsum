#!/usr/bin/env bash

#-----------------------------------------------------------------------------
# b3rsum
# Create and verify BLAKE3 hash sums from files or directories recursively.
# It uses GNU b3sum internally, and its output file is fully compatible.
#
##############################################################################
#
#    b3rsum Copyright © 2017, 2018, 2019, 2020 HacKan (https://hackan.net)
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
#
# Requirements
# ===============
#
#  - GNU Bash
#  - GNU b3sum which is part of the coreutils package.
#  - GNU Getopt which is part of the util-linux package.
#  - GNU parallel for improved performance.
#
#------------------------------------------------------------------------
# Changelog
#=====================
#
# v0.1.3
# - Greatly improve readme with use cases and help output.
# - Replace `tempfile` with `mktemp` which is more common among diff distros.
# - Replace `which` with `command -v` which is built-in.
#
# v0.1.2
# - Some changes in the order of info in help message.
# - Output option now accepts optional argument.
#
# v0.1.1
# - Fix check mode not reading inline data.
# - Fix length option being improperly parsed.
# - Bail out on wrong option.
#
# v0.1.0
# - First release.
#
# v0.0.1
# - Developing based on sharsum.
#
#------------------------------------------------------------------------

# Config
declare -r VERSION="0.1.3"
declare -r OUTPUT_FILENAME_DEFAULT="BLAKE3SUMS"
declare -r QUIET_DEFAULT=false
#--------------------------#

# Settings
# Do not edit unless you fully undestand these
declare -i -r EXIT_SUCCESS=0
declare -i -r EXIT_FAILURE=1
declare -i -r EXIT_WARNING=2
#--------------------------#

# Helpers
cout() {
	if ! ${QUIET} && ! ${VERY_QUIET}; then
		if [[ -f "$1" ]]; then
			cat "$1"
		else
			echo "$@"
		fi
	fi
}

warn() {
	if ! ${VERY_QUIET}; then
		echo "Warning: $*" >&2
	fi
	return $EXIT_WARNING
}

die() {
	# Show error and bail out
	if ! ${VERY_QUIET}; then
		echo "!!! Error: $*" >&2
	fi
	exit $EXIT_FAILURE
}

# Check sneaky paths, extracted from pass project
check_sneaky_paths() {
	local path
	for path in "$@"; do
		[[ $path =~ /\.\.$ || $path =~ ^\.\./ || $path =~ /\.\./ || $path =~ ^\.\.$ ]] && die "Please use paths without '..'"
	done
}
#--------------------------#

# Actions
check_output_file() {
	check_sneaky_paths "$OUTPUT_FILE"
	rm -f "$OUTPUT_FILE" > /dev/null 2>&1
	touch "$OUTPUT_FILE" > /dev/null 2>&1
	[[ -w "$OUTPUT_FILE" ]] || die "Selected output file '$OUTPUT_FILE' can't be written"
}

check_dependencies() {
	# Returns 0 if dependencies are installed, non-zero otherwise
	local -a DEPENDENCIES dep result
	DEPENDENCIES=( "b3sum" "getopt" "parallel" )
	result=0
	for dep in "${DEPENDENCIES[@]}"; do
		command -v "$dep" > /dev/null 2>&1
		result=$((result | $?))
	done
	return $result
}

cmd_license() {
	cat <<-_EOF
		${PROGRAM}: recursive BLAKE3 hash maker and verifier
		Copyright (C) 2020 HacKan (https://hackan.net)

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
	_EOF
}

cmd_version() {
	cat <<-_EOF
		${PROGRAM} v${VERSION} Copyright (C) 2020 HacKan (https://hackan.net)
	_EOF
}

cmd_help() {
	cmd_version
	cat <<-_EOF

		Usage: ${PROGRAM} [OPTION]... [FILE or DIRECTORY]...

		Print or check BLAKE3 checksums recursively.
		If no FILE or DIRECTORY is indicated, or it's a dot (.), then the current
		directory is processed.
		The default mode is to compute checksums. Check mode is indicated with --check.

		Options:
		  -c, --check                read BLAKE3 sums from the FILEs and check them
		  -o[FILE], --output[=FILE]  output to FILE instead of standard output, or a
		                             file named $OUTPUT_FILENAME_DEFAULT in the current
		                             directory if FILE is not specified
		  -q, --quiet                quiet mode: don't print messages, only hashes;
		                             during check mode, don't print OK for each
		                             successfully verified file
		  -s, --status               very quiet mode: output only hashes, no messages;
		                             status code shows success
		  --license                  show license and exit
		  --version                  show version information and exit
		  -h, --help                 show this text and exit

		The following four options are useful only when computing checksums:
		  -t, --text                 read in text mode (default)
		  -b, --binary               read in binary mode
		      --tag                  create a BSD-style checksum
		  -l, --length               digest length in bits; must not exceed the maximum
		                             for the blake2 algorithm and must be a multiple
		                             of 8

		The following three options are useful only when verifying checksums:
		      --ignore-missing  don't fail or report status for missing files
		      --strict         exit non-zero for improperly formatted checksum lines
		  -w, --warn           warn about improperly formatted checksum lines

		Sums are made using 'b3sum'. Full documentation at: 
		  <https://github.com/BLAKE3-team/BLAKE3>.
		The sums are computed as described in RFC 7693.  When checking, the input
		should be a former output of this program.  The default mode is to print a
		line with checksum, a space, a character indicating input mode ('*' for binary,
		' ' for text or where binary is insignificant), and name for each FILE.

		This program comes with ABSOLUTELY NO WARRANTY.
		This is free software, and you are welcome to redistribute it under certain
		conditions; type '$PROGRAM --license' for details.

		More information may be found in the ${PROGRAM}(1) man page.
	_EOF
}

cmd_create() {
	local -i ECODE=${EXIT_SUCCESS}
	local -a TOSCAN=( "$@" )
	local -i RESULT
	local EXEC

	[[ "${#TOSCAN[@]}" -eq 0 ]] && TOSCAN=(".")

	[[ -n "$OUTPUT_FILE" ]] && cout "Saving results in $OUTPUT_FILE"

	for item in "${TOSCAN[@]}"; do
		check_sneaky_paths "$item"

		if [[ "$item" == "-" ]]; then
			# shellcheck disable=SC2016
			EXEC='cat - | b3sum $([[ ${#B3SUM_OPTS[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS[*]}") -'
		elif [[ -e "$item" ]]; then
			# shellcheck disable=SC2016
			EXEC='find -L "$item" -type f ! -name "$OUTPUT_FILE" -print0 | parallel -0 b3sum $([[ ${#B3SUM_OPTS[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS[*]}") {}'
		else
			# shellcheck disable=SC2016
			EXEC='warn "File '$item' not found, skipping..."'
		fi
		
		if [[ -z "$OUTPUT_FILE" ]]; then
			eval "$EXEC"
		else
			eval "$EXEC" >> "$OUTPUT_FILE"
		fi
		RESULT=$?
		[[ $RESULT -ne 0 ]] && ECODE=$RESULT
	done

	return $ECODE
}

cmd_check() {
	local -i ECODE=${EXIT_SUCCESS}
	local -a HASHFILES=( "$@" )
	local -i RESULT
	local EXEC

	[[ -n "$OUTPUT_FILE" ]] && cout "Saving results in $OUTPUT_FILE"

	for hashfile in "${HASHFILES[@]}"; do
		check_sneaky_paths "$hashfile"

		if [[ "$hashfile" == "-" ]]; then
			# shellcheck disable=SC2016
			EXEC='cat - | b3sum --check $([[ ${#B3SUM_OPTS[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS[*]}") $([[ ${#B3SUM_OPTS_CHECK[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS_CHECK[*]}") -'
		elif [[ -r "$hashfile" ]]; then
			# shellcheck disable=SC2016
			EXEC='b3sum --check $([[ ${#B3SUM_OPTS[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS[*]}") $([[ ${#B3SUM_OPTS_CHECK[*]} -ge 1 ]] && printf "%s" "${B3SUM_OPTS_CHECK[*]}") "$hashfile"'
		else
			# shellcheck disable=SC2016
			EXEC='warn "File '$hashfile' not found or can not be accessed, skipping..."'
		fi

		if [[ -z "$OUTPUT_FILE" ]]; then
			eval "$EXEC"
		else
			eval "$EXEC" >> "$OUTPUT_FILE"
		fi
		RESULT=$?
		[[ $RESULT -ne 0 ]] && ECODE=$RESULT
	done

	return $ECODE
}
#--------------------------#

# Main
declare -r PROGRAM="${0##*/}"
declare -a B3SUM_OPTS=()
declare -a B3SUM_OPTS_CHECK=()
declare OPTS=''
declare MODE_CHECK=false
declare QUIET=$QUIET_DEFAULT
declare VERY_QUIET=false
declare OUTPUT_FILE=''

check_dependencies || die "Dependencies not met, can't continue"

# Arguments
OPTS="$(getopt -o hbctwsql:o:: -l help,version,license,binary,check,length:,text,tag,ignore-missing,quiet,status,strict,warn,output:: -n "$PROGRAM" -- "$@")"
# shellcheck disable=SC2181
[[ $? -ne 0 ]] && die "Wrong option. Try '$PROGRAM --help' for more information."

eval set -- "$OPTS"
while true; do case $1 in
	-h|--help)			cmd_help; exit $EXIT_SUCCESS;;
	--version)			cmd_version; exit $EXIT_SUCCESS;;
	--license)			cmd_license; exit $EXIT_SUCCESS;;
	-b|--binary)		B3SUM_OPTS+=( '--binary' ); shift;;
	-c|--check)			MODE_CHECK=true; shift;;
	-l|--length)		B3SUM_OPTS+=( '--length' "$2" ); shift 2;;
	--tag)				B3SUM_OPTS+=( '--tag' ); shift;;
	-t|--text)			B3SUM_OPTS+=( '--text' ); shift;;
	--ignore-missing)	B3SUM_OPTS_CHECK+=( '--ignore-missing' ); shift;;
	-q|--quiet)			QUIET=true; B3SUM_OPTS_CHECK+=( '--quiet' ); shift;;
	-s|--status)		VERY_QUIET=true; B3SUM_OPTS_CHECK+=( '--status' ); shift;;
	--strict)			B3SUM_OPTS_CHECK+=( '--strict' ); shift;;
	-w|--warn)			B3SUM_OPTS_CHECK+=( '--warn' ); shift;;
	-o|--output)		OUTPUT_FILE="${2:-$OUTPUT_FILENAME_DEFAULT}"
						check_output_file
						shift 2
						;;
	--) shift; break ;;
esac done

cout "$(cmd_version)" >&2
cout >&2

if $MODE_CHECK; then
	cmd_check "$@"
else
	cmd_create "$@"
fi

exit $?
