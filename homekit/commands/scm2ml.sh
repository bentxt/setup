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

cmd_scm2ml__run() {

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

    if ! [ -f "$input" ] || [ -z "$input" ]  ; then
        fail "no valid input '$input'"
        return 1
    fi

    local name=${input%.*}
    local out=$name.scm

    #camlp5 pa_scheme.cmo pr_o.cmo  -impl "$input" > "$out"
    camlp5 pa_sml.cmo pr_scheme.cmo  -impl "$input" > "$out"

}

cmd_scm2ml__main() {

    if [ -t 0 ] ; then 
        if [ $# -eq 0 ] ; then
            info "not enough args"
            perl -ne 's/^#+\s*//g; die "usage: $_" if($_ && $s); $s=1 if (/^SYNOPSIS\s*$/);' "$0" >&2
            exit 1
        fi
    else
        die 'Err: can not read from stdin'
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

}

cmd_scm2ml__main "$@" || die 'Abort cmd_scm2ml__main ...'
cmd_scm2ml__run "$@" || die 'Abort cmd_scm2ml__run ...'
