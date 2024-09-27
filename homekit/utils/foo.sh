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
# SYNOPSIS
#
#   template [OPTIONS] [filename], or run with --help
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
getos() { uname | tr '[:upper:]' '[:lower:]'; }

utils_template__run() {

    local input=
    while [ $# -gt 0 ]; do
        case "$1" in
        -*)
            info "invalid arg '$1', run --help"
            return 1
            ;;
        *)
            input="$1"
            shift
            break ;;
        esac
        shift
    done


    if [ -t 0 ]; then
        if ! [ -f "$input" ] || [ -z "$input" ]  ; then
            fail "no valid input '$input'"
            return 1
        fi
        echo "interactive input $input"
    else
        # perl -ne 'print'
        while read -r line ; do
            echo $line
        done
    fi
}


utils_template__main() {

    if [ $# -eq 0 ] ; then
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
            *) break ;;
        esac
        shift
    done
}

if [ -t 0 ]; then
    utils_template__main "$@" || die 'Abort utils_template__main ...'
fi

utils_template__run "$@" || die 'Abort utils_template__run ...'
