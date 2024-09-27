#!/bin/sh
#
# NAME
#
#   liblangs - utils around programming lanuages
#
# DESCRIPTION
#
# get_interpreter: get interpreter from lang extension
#
#

set -u

[ -z ${DEBUG+x} ] && DEBUG=

### Prelude

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
info() { echo "$*" >&2; }
warn() { 
    case "${1:-}" in
        '-verbose') 
            shift
            echo "Warn: $@" >&2
            ;;
        '-quiet') : ;;
        *)
            fail "invalid directive '${1:-}'" 
            return 1
            ;;
    esac
}

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


utils_liblangs__get_interp(){
    local input="${1:-}"
    if [ -z "$input" ] ; then
        fail  "Err: no input "
        return 1
    fi

    local ext=
    case "$input" in
        */*.*)
            local bname=; bname="$(basename "$input")"
            ext="${bname##*.}"
            ;;
        */*) : ;;
        *.*) ext="${input##*.}" ;;
        *) : ;;
    esac

    if [ -z "$ext" ] ; then
        fail "input has no extension '$input'"
        return 1
    fi


    local interp_path=
    case "$ext" in
        sh) interp_path="$(command -v dash)" ;;
        bash|dash) interp_path="$(command -v $ext)" ;;
        rb) interp_path="$(command -v ruby)" ;;
        pl) interp_path="$(command -v perl)" ;;
        py) interp_path="$(command -v python)" ;;
        *)
            [ -n "$DEBUG" ] && echo "Dbg: extension '$ext' not implemented, skip alias" >&2
            return 0
        ;;
    esac

    if [ -n "$interp_path" ]  ; then
        prn "$interp_path"
    else
        fail "could not set interp_path for '$ext'"
        return 1
    fi
}

