#!/bin/sh
#
# NAME
#
#   stamper - Template for shell scripts
#
# DESCRIPTION
#
#   Shell scripts that also can be used as modules/libraries for other scripts.
#   Fully posix compatible
#
# SYNOPSIS
#
#   stamper [COMMANDS] [filename], or run with --help
#
# COMMANDS
#
#   stamp <file/dir>       Stamp an existing file / dir
#
#   nf|newfile <name>         Create a new file / dir with a stamp
#   nw|newdir <name>
#
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

utils_stamper__init() {
    if ! [ -d "${MAINSCRIPT:-}" ]; then
        fail "invalid MAINSCRIPT in '${MAINSCRIPT:-}'"
        return 1
    fi
    
    . "$MAINSCRIPT/timestamp.dash"
}

utils_stamper__stamp_item(){
    local item="$1"
    local stamp="$2"

    local stamped_item=
    case "$item" in
        *.*)
            local name="${item%.*}"
            local ext="${item##*.}"
            stamped_item="${name}_${stamp}.$ext"
            ;;
        *)
            stamped_item="${item}_${stamp}"
            ;;
    esac

    prn "$stamped_item"
}



utils_stamper__new_stamp_item(){
    local item="$1"
    local stamp="$2"

    local stamped_item=
    stamped_item="$(utils_stamper__stamp_item "$item" "$stamp")"
    if [ -z "$stamped_item" ] ; then
        fail 'no stamped item'
        return 1
    fi

    if [ -e "$stamped_item" ] ; then 
        local new_stamp=
        new_stamp="$(utils_stamper__get_stamp_next)"

        local new_stamped_item= ; 
        new_stamped_item="$(utils_stamper__stamp_item "$item" "$new_stamp")"
        if [ -e "$new_stamped_item" ] ; then 
            fail "new stamped item is already there '$new_stamped_item'"
            return 1
        else
            prn "$new_stamped_item"
        fi
    else
        prn "$stamped_item"
    fi
}

utils_stamper__get_stamp_next(){
    sleep 1
    utils_timestamp__run -enc sqids second
}

utils_stamper__get_stamp_minute(){
    #echo utils_timestamp__run -enc sqids second >&2
    utils_timestamp__run -enc sqids minute

}


utils_stamper__run() {

    local cmd=
    while [ $# -gt 0 ]; do
        case "$1" in
        -*)
            info "invalid arg '$1', run --help"
            return 1
            ;;
        *) 
            cmd="$1"
            break ;;
        esac
        shift
    done

    if [ -n "$cmd" ] ; then
        shift
    else
        fail 'no cmd given'
        return 1
    fi
    local item="${1:-}"
    if [ -z "$item" ] ; then
        fail 'no item given'
        return 1
    fi

    local stamp=
    stamp="$(utils_stamper__get_stamp_minute)"
    if [ -z "$stamp" ] ; then
        fail 'could not get stamp_sec'
        return 1
    fi

    local new_item=
    new_item="$(utils_stamper__new_stamp_item "$item" "$stamp")"
    if [ -z "$new_item" ] ; then
        fail 'could not get stamp_sec'
        return 1
    fi

    case "$cmd" in
        nf|newfile) touch "$new_item" && echo "touch '$new_item'" ;;
        nd|newdir)  mkdir -p "$new_item" && echo "mkdir -p '$new_item'" ;;
        stamp)  mv "$item" "$new_item" && echo "mv '$item' '$new_item'";;
        *)
            fail "invalid cmd '$cmd'"
            return 1
            ;;
    esac
}


utils_stamper__main() {

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


#### Modulino

if [ -z "${MAINSCRIPT:-}" ]; then
    MAINSCRIPT="$(absdir "$(dirname "jsdf")")" 
    # . "$MAINSCRIPT/libutil.sh"
    if [ -t 0 ]; then
        utils_stamper__main "$@" || die 'Abort main ...'
    else
        die "Err: must be use interactively ..."
    fi
    utils_stamper__init  || die 'Abort init ...'
    utils_stamper__run "$@" || die 'Abort run ...'
else
    utils_stamper__init || {
        fail 'could not run init'
        return 1
    }
fi
