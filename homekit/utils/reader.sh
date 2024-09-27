#!/bin/sh
#
# NAME
#
#  reader - Read documents in a tmux READER window
#
# DESCRIPTION
#
#   read document in tmux buffer
#
# SYNOPSIS
#
#   [Options] [filename], or run with --help
#
# OPTIONS
#
#   --help          show help
#

set -eu

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
info() { echo "$@" >&2; }
die() {
    echo "$@" >&2
    exit 1
}

stamp() { date +'%Y%m%d%H%M%S'; }
absdir() (cd "${1}" && pwd -P)
help(){
    perl -ne 'print "$1\n" if /^\s*#\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
}

usage(){
    if [ -n "${1:-}" ] ; then
        echo "unknown option $1" >&2
    fi
    printf "usage %s: " "$(basename "$0" ".${0##*.}")" >&2
    perl -ne 'chomp;s/^#+\s*//g; if($s && $_){print " $_"; exit; };  $s=1 if(/^SYNOPSIS\s*$/) ' "$0"
}


utils_reader__driver(){
    local file="${1:-}"

    [ -f "$file" ] || {
        fail "not a valid file '$file'"
        return 1
    }

    tmux has-session -t 'READER' || { 
        fail 'needs a running tmux session named READER'
        return 1
    }

    local front_ps=
    front_ps="$(tmux list-panes -t READER -F '#{pane_current_command}')"

    case "$front_ps" in
        more) echo Fuuuuuuyess ;;
        *)
            tmux send-keys -t 'READER' "more $file" Enter
            ;;
    esac

}

utils_template__run() {

    local file=

    while [ $# -gt 0 ]; do
        case "$1" in
        -h | --help)
            help
            return 1
            ;;
        -*)
            usage "$1"
            return 1
            ;;
        *) 
            file="$1"
            break ;;
        esac
        shift
    done

    if [ $# -eq 0 ]; then
        info "no input "
        usage
        return 1
    fi
    if ! [ -f "$file" ]; then
        fail "file not exists '$file' "
        return 1
    fi

    if tmux info > /dev/null 2>&1; then 
        utils_reader__driver "$file"
    else
        fail 'tmux is not yet running'
        return 1
    fi

}

utils_template__run "$@"
