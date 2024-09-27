#!/bin/sh
#
# NAME
#
#   linkto - link a file to target
#
# DESCRIPTION
#
#   link a file to a target, main usage is in aliases
#
#
# SYNOPSIS
#
#   linkto <dir> <file>, or run with --help
#
# OPTIONS
#
#   --help          show help
#

set -eu

[ -z ${DEBUG+x} ] && DEBUG=

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
abspath() { perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "$1"; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }

main() {

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

    local target_dir="$1"
    if [ -z "$target_dir" ] ; then
        fail 'not target_dir'
    fi
    local target_name="${2:-}"

    # target_dir
    [ -d "$target_dir" ] || die "Err: no valid target_dir"

    # source
    local source="$PWD" 
    local source_abspath="$(abspath "$source")"
    if ! [ -e "$source_abspath" ] ; then
        fail "source_abspath does not exists '$source_abspath'"
        return 1
    fi

    # target_name
    [ -z "$target_name" ] && target_name="${source##*/}"
    rm -f "$target_dir/$target_name"

    if [ -L "$source" ] ; then
        cp -P "$source" "$target_dir/$target_name"
    else
        ln -s  "$source" "$target_dir/$target_name"
    fi
}


if [ -t 0 ]; then
    main "$@" || die 'Abort utils_template__main ...'
else
    die 'Err: run program interactively'
fi
