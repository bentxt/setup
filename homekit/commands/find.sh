#!/bin/sh
#
# NAME
#
#   ,find  - comma-find 
#
# DESCRIPTION
#
#   Depending on number of args:
#
#   - 1 arg => find . -iname "*${1}*" 
#
#   - 2 arg => find "${2}" -iname "*${1}*" 
#
# SYNOPSIS
#
#   ,find [OPTIONS] [filename], or run with --help
#
# OPTIONS
#
#   --help          show help
#

set -eu

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
warn() { echo "Warn: $*" >&2; }
info() { echo "$@" >&2; }
die() {
    echo "$@" >&2
    exit 1
}

stamp() { date +'%Y%m%d%H%M%S'; }
absdir() (cd "${1}" && pwd -P)

comma_find__main() {

    if [ -t 0 ] && [ $# -eq 0 ] ; then
        info "not enough args"
        perl -ne 's/^#+\s*//g; die "usage: $_" if($_ && $s); $s=1 if (/^SYNOPSIS\s*$/);' "$0" >&2
        exit 1
    fi

    while [ $# -gt 0 ]; do
        case "${1:-}" in
            -h | --help)
                perl -ne 'print "$1\n" if /^\s*#\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
                exit 1
            ;;
            -*) break ;;
            *) break ;;
        esac
        shift
    done

    case $# in
        0) find ;;
        1) find "$PWD" -iname "*${1}*" ;;
        2) find "${2}" -iname "*${1}*" ;;
        *) die "Err: too many args" ;;
    esac

}

comma_find__main "$@" || die 'Abort commands_findi__main ...'
