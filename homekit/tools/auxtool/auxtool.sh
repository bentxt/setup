#!/bin/sh
#
USAGE='-ext=file-extension [run new | edit | list | golf | degolf | shfunc | alias] [token] [filter ...]'

set -u

auxdir="$HOME/aux"
            
selfdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

die(){
    echo "$*" >&2
    exit 1
}
warn(){ echo "$*" >&2; }

[ -d "$auxdir" ] || die "Err: auxdir not exists in $auxdir"


item_from_owl_list='item_from_owl_list__jUAWAzpA'
item_from_owl_list_sh="$HOME/aux/functions/$item_from_owl_list.sh"
if [ -f "$item_from_owl_list_sh" ] ; then
    . "$item_from_owl_list_sh"
else
    die "Err: cannot get $item_from_owl_list_sh"
fi

findfiles_owl_list='findfiles_owl_list__QKaRaY2A'
findfiles_owl_list_sh="$HOME/aux/functions/$findfiles_owl_list.sh"
if [ -f "$findfiles_owl_list_sh" ] ; then
    . "$findfiles_owl_list_sh" 
else
    die "Err: cannot get $findfiles_owl_list_sh"
fi

getpath='getpath__hw6g6NRX'
getpath_sh="$HOME/aux/functions/$getpath.sh"
if [ -f "$getpath_sh" ] ;then
    . "$getpath_sh"
else
    die "Err: cannot get $getpath_sh"
fi


lib_plx="$HOME/aux/tools/auxtool/lib_plx.sh"
[ -f "$lib_plx" ] || die "Err: cannot get lib_plx"

action_input=
check_existing=1
file_extension=
while [ $# -gt 0 ] ; do
    case "${1:-}" in
        -h|--help|h|help) die "usage: $USAGE" ;;
        -ext=*) file_extension="${1#*=}" ;;
        -*) die "Err: invalid option $1";;
        *) 
            action_input="${1:-}"
            shift
            break
            ;;
    esac
    shift
done


[ -n "$action_input" ] || die "no action input, usage: $USAGE"

action=
case "${action_input}" in
    r|run) action='run';;
    n|new) 
        check_existing=0
        action='new'
        ;;
    ls|list-show) action='show' ;;
    le|list-edit) action='edit' ;;
    lg|list-golf) action='golf' ;;
    ld|list-degolf) action='degolf' ;;
    lw|list-wrap) action='wrap' ;;
    e|edit) action='edit';;
    l|list) action='list';;
    g|golf) action='golf';;
    d|degolf) action='degolf';;
    s|shfunc) action='shfunc';;
    a|alias) action='alias';;
    *) die "Err: unknown action $1";;
esac

token="${1:-}"
[ -n "$token" ] && shift

list_dir=
case "$token" in
    *:*) 
        [ -n "$file_extension" ] && die "Err: file extension already set"
        file_extension="${token##*:}" 
        subdir="${token%:*}"
        list_dir="$auxdir/$subdir"
        ;;
    *) list_dir="$auxdir/$token" ;;
esac


file_path=
case "$action_input" in
    list-show|ls|l)
        file_list="$(${findfiles_owl_list}  -min=1 -ext="$file_extension" -args="-maxdepth 1"  "$list_dir")"
        [ -n "$file_list" ] || die "Sorry: no file list for : $list_dir"
        ${item_from_owl_list} list "$file_list" $@
        exit
        ;;
    list-*|l[a-z])
        file_list="$(${findfiles_owl_list}  -min=1 -ext="$file_extension" "$list_dir")"
        [ -n "$file_list" ] || die "Sorry: no file list for : $list_dir"
        file_result="$(${item_from_owl_list}  choose "$file_list" $@)"
        [ -n "$file_result" ] || die "Err: no file result"
        file_path="$(${getpath} -check="$check_existing" "$list_dir"  "${file_result}" "$file_extension")" || die "Err: could not get file_path"
        ;;
    *) file_path="$token" ;;
esac

[ -n "$file_path" ] || die "Err: no file path"
[ -f "$file_path" ] || die "Err: xno valid file path: $file_path"



case "$action" in
    edit) 
        echo "$file_path"
        echo '----'
        read -p "edit? [Y|n]" doedit
        case "$doedit" in
            n|N) 
                warn "bye" 
                exit 
                ;;
            *) : ;;
        esac
        vim "$file_path"
        ;;
    list-new|new|n)
        filedir="$(dirname "$file_path")"
        if [ -e "$filedir" ]; then
            [ -d "$filedir" ] || die "Err: '$filedir' is not a dir"
        else
            mkdir -p "$filedir"
        fi
        touch "$file_path"
        echo "$file_path"
        ;;
    list-shfunc|s)
        plxcmd="$(get_plxcmd "$file_path")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        plxbasename="$(basename "$file_path")"
        plxname="${plxbasename%.*}"

        echo "$plxname(){"
            echo "   # $plxbasename:"
            printf "   %s -e '" "$plxcmd"
            perl -w -n "$selfdir/plx-golf.plx" "$file_path"
            echo "' "' "$@"'
        echo '}'
        ;;
    alias)
        [ -f "$file_path" ] || die "Err: file_path '$file_path'  not valid"
        plxcmd="$(get_plxcmd "$file_path")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        plxbasename="$(basename "$file_path")"
        plxname="${plxbasename%.*}"

        printf "alias %s='%s -e '" "$plxname" "$plxcmd"
        perl -w -n "$selfdir/plx-golf.plx" "$file_path"
        echo "' "
        ;;
    golf)
        [ -f "$file_path" ] || die "Err: file_path '$file_path'  not valid"
        perl -w -n "$selfdir/plx-golf.plx" "$file_path"
        ;;
    degolf)
        [ -f "$file_path" ] || die "Err: file_path '$file_path'  not valid"
        [ $# -gt 0 ] || die "Err: too few args"
        perl -w -n "$selfdir/plx-degolf.plx" "$@"
        ;;
    run)
        [ -f "$file_path" ] || die "Err: file_path '$file_path'  not valid"

        plxcmd="$(get_plxcmd "$file_path")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        ${plxcmd} "$file_path" "$@"
        ;;
    *)
        die "Err: invalic action $action"
        ;;
esac


