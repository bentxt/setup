#!/bin/sh
#
# NAME
#
#   libio - io library
#
# DESCRIPTION
#
#
# Different utils when working on filesystem
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

timestamp() { date +'%Y%m%d%H%M%S'; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }
getlines() { wc -l <"${1:-}" | tr -d ' '; }
newpath() { case "$1" in */*) prn "${1%/*}/$2" ;; *) prn "$2" ;; esac }
newpathext() { newpath "$1" "$(basename "$1" "${1##*.}")$2"; }

abspath() {
	readlink -f "${1}" 2>/dev/null || {
		perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "${1}"
	}
}


utils_libio__inode_dir() {
    local dir="${1:-}"
    if [ -z "$dir" ] ; then
        fail "no dir"
        return 1
    fi
    if ! [ -d "$dir" ] ; then
        fail "no dir '$dir'"
        return 1
    fi

    
    local dir_inode=; dir_inode="$(ls -id "$dir")"
    if [ -z "$dir_inode" ] ; then
        fail "no dir inode '$dir_inode'"
        return 1
    fi

    local dir_id=; dir_id="${dir_inode%% *}"
    case "$dir_id" in
        ''|*[!0-9]*)
            fail "invalid id, not a number '$dir_id'"
            return 1
            ;;
        *): ;;
    esac

    prn "$dir_id"
}


utils_libio__save_file_contents() {
    local dir="${1:-}"
    if [ -n "$dir" ] ; then
        shift
    else
        fail "no dir given"
        return 1
    fi

    local filename="${1:-}"
    if [ -n "$filename" ] ; then
        shift
    else
        fail "no filename given"
        return 1
    fi


    case "$filename" in
        */*) 
            fail "invalid filename '$filename'"
            return 1
            ;;
        *) : ;;
    esac

    local content=
    if [ -n "${1:-}" ] ; then
        content="$1"
        shift
    else
        fail 'no content to save'
        return 1
    fi

    while [ $# -gt 0 ] ; do 
        content="${content}"'\n'"${1}"
        shift
    done


    local file_path="$dir/$filename"

    if [ -f "$file_path" ] ; then
        if ! echo "$content" | diff "$file_path" - ; then 
            fail "file path '$file_path' is the same but content differs ('$content')"
            return 1
        fi
    else
        mkdir -p "$dir" 
        echo "$content" > "$file_path"
    fi

    echo "$file_path"
}

