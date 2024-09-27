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



link_dotfiles(){

    for fso in $HOME/.*; do
        [ -e "$fso" ] || continue

        fsod="${fso%/*}"
        fsob="${fso##*/}"

        [ "$fsod" = "$fsob" ] && {
            echo "something wrong with '$fso'"
            continue
        }
        
        case "$fsob" in
            .|..) echo "Invalid fsob '$fsob', skipping " 
                continue
                ;;
            $fsod)
                echo "something wrong with '$fso' ('$fsob' vs '$fsod'), skipping"
                continue
                ;;
            *)
        esac

        libmain__link_to_target "$fso" "$BASEJUMP/$fsob"

    done
}


mkdir -p "$BASEJUMP"/home
for fso in $HOME/*; do
    [ -e "$fso" ] || continue

    fsod="${fso%/*}"
    fsob="${fso##*/}"
    
    [ "$fsod" = "$fsob" ] && {
        echo "something wrong with '$fso'"
        continue
    }

    case "$fsob" in
        [A-Z]*) libmain__link_to_target "$fso" "$BASEJUMP/home/$fsob" ;;
        *) : ;;
    esac
done


for d in "$HOMEBASE"/*; do
    [ -d "$d" ] || continue
    local bd="${d##*/}"
    local ad=
    ad="$(libmain__abspath "$d")" || die "Err: could not get abspath of $d"

    case "$bd" in 
        jump|j) continue ;;
        top)
            for dd in "$d"/*; do
                [ -d "$dd" ] || continue
                local add=
                add="$(libmain__abspath "$dd")" || die "Err: could not get abspath of $dd"
                local bdd=
                bdd="${dd##*/}"
                

                case "$bdd" in
                    *.*.*) die "Err: please only one '-' dir '$bdd'" ;;
                    *.*)
                        local topfolder=; topfolder="${bdd%.*}s"
                        mkdir -p "$BASEJUMP/$topfolder"
                        libmain__link_to_target "$dd" "$BASEJUMP/$topfolder/$bdd"

                        local acclvl="${bdd##*.}"
                        #"$(echo "${PWDNAME%.*}"s | tr '[:upper:]' '[:lower:]')"
                        for ddd in "$add"/* ; do 
                            [ -d "$ddd" ] || continue
                            local addd=; addd="$(libmain__abspath "$ddd")" || die "Err: could not get abspath of $ddd"
                            lcal bddd=; bddd="${ddd##*/}"
                            local linkname="$bddd.$acclvl"
                            libmain__link_to_target "$addd" "$BASEJUMP/$linkname"
                        done
                        ;;
                    *) die "Err: no dash dirname '$bdd'";;
                esac
            done
            ;;
        *) 
            for dd in "$d"/*; do
                [ -d "$dd" ] || continue
                local add=; add="$(libmain__abspath "$dd")" || die "Err: could not get abspath of $dd"
                local bdd="${dd##*/}"
                libmain__link_to_target "$add" "$BASEJUMP/$bdd"
            done
            ;;
    esac

    libmain__link_to_target "$ad" "$BASEJUMP/$bd"

done
        


run() {

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

    HOMEBASE="$HOME/base"
    BASEJUMP="$HOMEBASE/jump"

    mkdir -p "$BASEJUMP"


}


main() {

    UTILS_MAINSCRIPT_DIR="$(absdir "$(dirname "$0")")"
    . "$UTILS_MAINSCRIPT_DIR/libmain.sh"

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
            -*) break ;;
            *) break ;;
        esac
        shift
    done
}



main "$@" || die 'Abort main ...'
run "$@" || die 'Abort run ...'
