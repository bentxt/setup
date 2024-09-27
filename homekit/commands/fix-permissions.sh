#!/bin/sh
#
# NAME
#
#   fix-permissions
#
# DESCRIPTION
#
# reset to default permissions like removing executable flag
#
# see also default-permissions.sh
# sets files and folders back to their default permissions
#
#
# SYNOPSIS
#
#   fix-permissions , or run with --help
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


main() {

    if [ $# -eq -1 ] ; then
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
        
    inputdir="${1:-}"

    [ -z "$inputdir" ]  && inputdir="$PWD"

    [ -d "$inputdir" ] || die "Err: invalid dir"


    #for directories
    find -L "$inputdir"/ -type d -print0 | xargs -0 -I{}  chmod 0755 {}

    # for files

    find -L  "$inputdir"/ -type f -print0 | xargs -0 -I{} chmod 0644 {}
}


if [ -t 0 ]; then
    main "$@" || die 'Abort main ...'
else
    die 'Err: run program interactively'
fi
