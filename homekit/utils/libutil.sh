#!/bin/sh
#
# NAME
#
#   template - Template for shell scripts
#
# DESCRIPTION
#
#   Shell scripts that also can be used as modules/libraries for other scripts.
#   Fully posix compatible
#
#
# SYNOPSIS
#
#   template [OPTIONS] [filename], or run with --help
#
# OPTIONS
#
#   --help          show help

set -u

[ -z ${DEBUG+x} ] && DEBUG=

utils_libutil__get_md5sum(){
    local string="${1:-}"
    if [ -z "$string" ] ; then
        fail 'no string'
        return 1
    fi
    perl -MDigest::MD5 -e 'print Digest::MD5::md5_base64($ARGV[0]);' "$string"

    #if [ -z "${UNIVERSAL_BIN_MD5SUM:-}" ] ; then
    #    command -v md5sum > /dev/null || {
    #        fail 'no md5sum'
    #        return 1
    #    }
    #else
    #    echo "${string}" | md5sum | cut -d ' ' -f 1
    #fi

}


### Prelude

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
warn() { echo "Warn: $*" >&2; }
info() { echo "$@" >&2; }

timestamp() { date +'%Y%m%d%H%M%S'; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }
getlines() { wc -l <"${1:-}" | tr -d ' '; }
newpath() { case "$1" in */*) prn "${1%/*}/$2" ;; *) prn "$2" ;; esac }
newpathext() { newpath "$1" "$(basename "$1" "${1##*.}")$2"; }

die() {
	echo "$@" >&2
	exit 1
}
abspath() {
	readlink -f "${1}" 2>/dev/null || {
		perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "${1}"
	}
}

