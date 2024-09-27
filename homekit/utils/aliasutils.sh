#!/bin/sh
#
# NAME
#
#   aliasutils - utils for the handling of aliases
#
# DESCRIPTION
#
#   generate alias files that can be then sourced from shell init
#
# SYNOPSIS
#
#   aliasutils [command] <dirs ... >
#
# COMMANDS
#
#   gen|generate:       generate from a bunch of directories
#   base-gen|base-generate  generate from a base directory
#   home                print cache dir
#   ls|list             list cache dir
#   clean               clean cache dir
#
#   --help          show help
#

set -u

[ -z "${DEBUG+x}" ] && DEBUG=

UTILS_ALIASUTILS__CACHEDIR=

utils_aliasutils__init(){
    local maindir="${1:-}"

    local cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
    if [ -d "$cache_home" ] ; then
        UTILS_ALIASUTILS__CACHEDIR="$cache_home/utils_aliasutils"
    else
        fail "There is no cache home in '$cache_home'"
        return 1
    fi

    if [ -d "${maindir}" ]; then
        local inc
        for inc in 'liblangs.sh' ; do
            if [ -f "$maindir/$inc" ] ; then
                . "$maindir/$inc" || {
                    fail "could not incluce '$maindir/$inc'"
                    return 1
                }
            else
                fail "could not find library include '$maindir/$inc'"
                return 1
            fi
        done
    else
        fail "invalid maindir  '${maindir}'"
        return 1
    fi


}


utils_aliasutils__run() {

	while [ $# -gt 0 ]; do
		case "$1" in
		-*)
			info "invalid arg '$1', run --help"
			return 1
			;;
		*) break ;;
		esac
		shift
	done

	local cmd="${1:-}"
    if [ -n "$cmd" ]; then
        shift
    else
        fail "no cmd"
        return 1
    fi

    local cachedir=;
        cachedir="$(utils_aliasutils__cachedir)" || {
        fail 'could not dreate cachedir'
        return 1
    }

    if [ -z "$cachedir" ] ; then
        fail empty cachedir
        return 1
    fi

    
    case "$cmd" in
        clean) utils_aliasutils__clean "$cachedir" ;;
        ls|list)
            if [ -d "$cachedir" ] ; then
                echo "cachedir '$cachedir':"
                ls "$cachedir"/*
            else
                fail 'invalid cachedir'
                return 2
            fi
        ;;
        home) 
            if [ -d "$cachedir" ] ; then
                echo "cachedir '$cachedir'"
            else
                fail 'invalid cachedir'
                return 1
            fi
            ;;
        gen|generate)
            if [ $# -eq 0 ] ; then
                fail 'no dirs given'
                return 1
            fi
            local dir=
            for dir in $@; do
                if [ -d "$dir" ] ; then
                    utils_aliasutils_generate "$cachedir" "$dir" ','
                else
                    info "dir '$dir' not exists, skipping"
                fi
            done
            ;;
        base-gen|base-generate)
            if [ $# -eq 0 ] ; then
                fail 'no dirs given'
                return 1
            fi

            local basedir="${1:-}"

            if [ -d "$basedir" ] ; then
                shift
            else
                fail "basedir '$basedir' not exists"
                return 1
            fi


            local folder=
            for folder in $@; do
                local dir="$basedir/$folder"
                if [ -d "$dir" ] ; then
                    utils_aliasutils_generate "$cachedir" "$dir" ','
                else
                    info "dir '$dir' not exists for folder '$folder', skipping"
                fi
            done
            ;;
        *)
            fail 'invalid cmd'
            return 1
            ;;
    esac

}

utils_aliasutils__clean() {
    local cachedir="${1:-}"
    if [ -z "$cachedir" ] ; then
        fail no cachedir given
        return 1
    fi

    if [ -d "$cachedir" ] ; then
        echo "cleaning '$cachedir':"
        rm -f  "$cachedir"/*
    else
        fail 'invalid cachedir'
        return 2
    fi
}


utils_aliasutils__cachedir(){

    if [ -n "$UTILS_ALIASUTILS__CACHEDIR" ]; then
        if [ -d "$UTILS_ALIASUTILS__CACHEDIR" ] ; then
            prn "$UTILS_ALIASUTILS__CACHEDIR"
        else
            if mkdir -p "$UTILS_ALIASUTILS__CACHEDIR" ; then
                prn "$UTILS_ALIASUTILS__CACHEDIR"
            else
                fail "could not create '$UTILS_ALIASUTILS__CACHEDIR'"
                return 1
            fi
        fi
    else
        fail 'no alias_cache'
        return 1
    fi
}



utils_aliasutils_generate(){
    local cachedir="${1:-}"

    if [ -z "$cachedir" ] ; then 
        fail "Err: no cachedir "
        return 1
    fi
    local aliasdir="${2:-}"

    if [ -z "$aliasdir" ] ; then 
        fail "Err: no aliasdir "
        return 1
    fi

    local prefix="${3:-}"


    if ! [ -d "$cachedir" ] ; then 
        fail "Err: no valid cachedir in '$cachedir'"
        return 1
    fi

    local utilsbase=; utilsbase="$(basename "$aliasdir")"

    case "$utilsbase" in
        '.'|'..') 
            fail 'need an named directory and not ., or ..'
            return 1
            ;;
        *) : ;;
    esac

    local aliasfile="$cachedir/$utilsbase.sh"

    if [ -f "$aliasfile" ] ; then
        info "info: overwriting aliasfile '$aliasfile'"
        rm -f "$aliasfile"
    fi

    for scriptfile in "$aliasdir"/*; do
        [ -f "$scriptfile" ] || continue

        bname="$(basename "$scriptfile")"
            
        case "$bname" in
            _*|lib*) continue;;
            *)
                name="${bname%.*}"
                ext="${bname##*.}"

                local interp=;
                interp="$(utils_liblangs__get_interp "$bname")" 
                if [ -n "$interp" ] ; then
                    [ -n "$DEBUG" ] && echo "alias ${prefix}${utilsbase}-${name}=$interp $scriptfile"
                    echo "alias ${prefix}${utilsbase}-${name}='$interp $scriptfile'" >> "$aliasfile"
                else
                    info skip $bname
                fi
            ;;
        esac
    done
}



### Prelude

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
info() { echo "$*" >&2; }
warn() { 
    case "${1:-}" in
        '-verbose') 
            shift
            echo "Warn: $*" >&2
            ;;
        '-quiet') : ;;
        *)
            fail "invalid directive '${1:-}'" 
            return 1
            ;;
    esac
}

timestamp() { date +'%Y%m%d%H%M%S'; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }
getlines() { wc -l <"${1:-}" | tr -d ' '; }
newpath() { case "$1" in */*) prn "${1%/*}/$2" ;; *) prn "$2" ;; esac }
newpathext() { newpath "$1" "$(basename "$1" "${1##*.}")$2"; }

die() {
	echo "$@" >&2
	exit 1
}
abspath() {
	readlink -f "${1}" 2>/dev/null || {
		perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "${1}"
	}
}

usage() {
    info "not enough arguments"
	for regex in 's/^#+\s*//g; if($_ && $s){print "usage: $_"; exit 0; };  $s=1 if (/^SYNOPSIS\s*$/);' 'if (/^\s*#+\s*([uU]sage[a-z\s-_]*:.*)\s*/){print "$1"; $s=1; exit 0 ; };'; do
		perl -ne "${regex}"';END{exit 1 unless $s;}' "$0" >&2 && exit 1
	done
    exit 1
}

main() {
	local argnum="$1"
	shift

	[ $# -eq $argnum ] && usage

    local arg
    for arg in "$@" ; do
        case "${arg}" in
            -h | --help)
                perl -ne 'print "$1\n" if /^\s*#+\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
                exit 1
                ;;
            *) : ;;
        esac
    done
}

### Modulino

if [ -z "${MAINSCRIPT:-}" ]; then
	MAINSCRIPT="$(abspath "$0")"
    [ -z "$MAINSCRIPT" ] && die "Err: could not set MAINSCRIPT"
	if [ -t 0 ]; then
		main 0 "${@}"
	else
		die "Err: cannot run as part of a pipe ..."
	fi
	utils_aliasutils__init "${MAINSCRIPT%/*}" || die 'Abort init ...'
	utils_aliasutils__run "$@" || die 'Abort run ...'
else
	utils_aliasutils__init "${MAINSCRIPT%/*}" || {
		fail 'could not run init'
		return 1
	}
fi
