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

### Prelude

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
warn() { echo "Warn: $*" >&2; }
info() { echo "$@" >&2; }

die() {
	echo "$@" >&2
	exit 1
}
abspath() {
	readlink -f "${1:-}" 2>/dev/null || {
		perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "${1:-}"
	}
}

usage() {
	for regex in 's/^#+\s*//g; if($_ && $s){print "usage: $_"; exit 0; };  $s=1 if (/^SYNOPSIS\s*$/);' 'if (/^\s*#+\s*([uU]sage[a-z\s-_]*:.*)\s*/){print "$1"; $s=1; exit 0 ; };'; do
		perl -ne "${regex}"';END{exit 1 unless $s;}' "$0" >&2 && exit 1
	done
}

timestamp() { date +'%Y%m%d%H%M%S'; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }
getlines() { wc -l <"${1:-}" | tr -d ' '; }
getnewfile() { case "$1" in */*) prn "${1%/*}/$2" ;; *) prn "$2" ;; esac }
getnewfilext() { getnewfile "$1" "$(basename "$1" "${1##*.}")$2"; }

main() {


    local regex=
    local opt_probe=
	while [ $# -gt 0 ]; do
		case "${1:-}" in
		-h | --help)
			perl -ne 'print "$1\n" if /^\s*#+\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
			exit 1
			;;
        -p| --probe)
            opt_probe=1
            ;;
		-*) #die "Err: invalid arg"
			break
			;;
		*) regex="$1"
            shift
            break ;;
		esac
		shift
	done


    [ -n "$regex" ] || usage

    local dir="${1:-}"

    [ -n "$dir" ] || dir='./'
    [ -d "$dir" ] || die "Err: no dir '$dir'"

    if [ -n "$opt_probe" ] ; then
        perl -p -e "$regex"  "$dir"/*
    else
       perl -pi.bak -e "$regex" "$dir"/*
   fi

}

main $@
