#!/bin/sh
#
USAGE='[--[h]elp], [--[n]ew] [--[e]dit]   [--[l]ist|--[g]olf|--[d]egolf | --[s]hfunc [file|term] | --[a]lias'
set -u

            
funcdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


die(){
    echo "$*" >&2
    exit 1
}

warn(){ echo "$*" >&2; }

arg=
action=
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help) die "usage: $USAGE" ;; 
        -n|--new) action='new';;
        -e|--edit) action='edit';;
        -l|--list) action='list';;
        -g|--golf) action='golf';;
        -d|--degolf) action='degolf';;
        -s|--shfunc) action='shfunc';;
        -a|--alias) action='alias';;
        -*) die "Err: invalid option" ;;
        *) 
            arg="$1"
            shift
            break 
            ;;
    esac
    shift
done

get_funcpath(){
    local funcfile="${1:-}"
    [ -n "$funcfile" ] || die "Err: no funcfile given"

    local no_check="${2:-}"

    local funcpath
    case "$funcfile" in
        /*.sh|.*.sh|/*.fish|.*.fissh) funcpath="$funcfile" ;;
        */*.sh|*/*.fish)  
            local dname="$(dirname "$funcfile")"
            mkdir -p "$funcdir/$dname"
            funcpath="$funcdir/$funcfile" 
            ;;
        *.sh|*.fish)  die "Err: is funcfile, but need sub dir: $funcfile" ;;
        *) die "Err: is not looking like a plx file" ;;
    esac

    if [ -f "$funcpath" ] ; then
        printf "%s" "$funcpath"
    else
        if [ -n "$no_check" ] ; then
            printf "%s" "$funcpath"
        else
            die "Err: no valid funcfile $funcpath given"
        fi

    fi

}

get_interpreter(){
    local funcfile="${1:-}"
    
    local funcpath="$(get_funcpath "${funcfile}")" || die "Err: could not get funcpath"
    [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"

    local interp="$(perl -e '$ARGV[0] =~/\.([^.]+)$/ && print($1)' "$funcpath")"

    [ -n "$interp" ] || die "Err: could not get interpreter, from '$funcpath'"

    printf "%s" "$interp"

}

get_argnum(){
    local funcfile="${1:-}"
    
    local funcpath="$(get_funcpath "${funcfile}")" || die "Err: could not get funcpath"
    [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"


    local argnum="$(perl -e '$ARGV[0] =~/(\d+)\.[^.]+$/ && print($1)' "$funcpath")"

    [ -n "$argnum" ] || die "Err: could not get argnum from '$funcpath'"

    printf "%s" "$argnum"

}



if [ -n "$action" ] ; then
    case "$action" in
        new)
            funcpath="$(get_funcpath "${arg}")" || die "Err: could not get funcpath"
            [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"
            touch "$funcpath" || die "Err: could not touch '$funcpath'"
            echo "$funcpath"
            ;;
        edit)
            funcpath="$(get_funcpath "${arg}")" || die "Err: could not get funcpath"
            [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"
            vim "$funcpath"
            exit
            ;;
        func)
            funcpath="$(get_funcpath "${arg}")" || die "Err: could not get funcpath"
            [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"

            argnum="$(get_argnum "$funpath")" || die "Err: could not get argnum from '$funcpath'"
            [ -n "$argnum" ] || die "Err: could not get plxcmd"

            func_basename="$(basename "$funcpath")"
            funcname="${func_basename%.*}"

            echo "$funcname(){"
                echo '   if [ $# -lt '$argnum' ] ; then' 
                echo '      echo "not enough args" >&2' 
                echo '      exit 1' 
                echo '   fi'
                cat "$funcpath"
                echo '}'
                echo ''

            ;;
        alias)
            die "TODO: golfing for shell scripts"
            funcpath="$(get_funcpath "${arg}")" || die "Err: could not get funcpath from '$arg'"
            [ -f "$funcpath" ]  || die  "err: invalid func file: $funcpath"

            interpreter="$(get_interpreter "$funpath")" || die "Err: could not get interpreter from '$funcpath'"
            [ -n "$interpreter" ] || die "Err: could not get interpreter"

            func_basename="$(basename "$funcfile")"
            funcname="${func_basename%.*}"

            #printf "alias %s='%s -e '" "$funcname" "$plxcmd"
            #perl -w -n "$funcdir/plx-golf.plx" "$funcfile"
            #echo "' "
            ;;
        golf)
            die "TODO: golfing for shell scripts"
            funcfile="$(get_funcfile "${arg}")" || die "Err: could not get funcfile"
            perl -w -n "$funcdir/plx-golf.plx" "$funcfile"
            ;;
        degolf)
            die "TODO: golfing for shell scripts"
            [ $# -gt 0 ] || die "Err: too few args"
            perl -w -n "$funcdir/plx-degolf.plx" "$@"
            ;;
        list)
            cd "$funcdir"
            if [ -n "${1:-}" ] ; then
                find "." -mindepth 2 -type f -iname '*.plx' | grep -i "$1"
            else
                find "." -mindepth 2 -type f -iname '*.plx'
            fi

            ;;
        *)
            die "Err: invalic action $action"
            ;;
    esac
else
    funcpath="$(get_funcfile "${arg}")" || die "Err: could not get funcpath from '$arg'"
    [ -f "$funcpath" ]  || die "Err: could not find file funcpath"
    case "$funcfile" in
        *.plx) : ;;
        *) die "Err: does not look like plx file: $funcfile" ;;
    esac

    plxcmd="$(get_argnum "$funcfile")" || die "Err: could not get plxcmd"
    [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

    ${plxcmd} "$funcfile" "$@"
fi



