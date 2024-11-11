#!/bin/sh
#
USAGE='-ext=file-extension <run|new|edit|list|golf|degolf|shfunc|alias> <basedir>  [token] [filter ...]'

set -u
            
selfdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
homekit="$HOME/kit"

die(){
    echo "$*" >&2
    exit 1
}
warn(){ echo "$*" >&2; }

[ -d "$homekit" ] || die "Err: homekit missing"

state_home=
if [ -n "$XDG_STATE_HOME" ] ; then
    state_home="$XDG_STATE_HOME"
else
    state_home="$HOME/.local/state"
fi
[ -d "$state_home" ] || die "Err: state home not exists under $state_home"


state_dir="$state_home/kit"
[ -d "$state_dir" ] || mkdir -p "$state_dir"


directory_action=
file_action=
file_ext=
check_existing=1
needs_file=1
opt_set=
while [ $# -gt 0 ] ; do
    case "${1:-}" in
        -h|--help|h|help) die "usage: $USAGE" ;;
        -set) file_action=set ;;
        -ext=*) file_ext="${1#*=}" ;;
        -*) die "Err: invalid option $1";;
        fs|find-set) 
            directory_action='find'
            file_action='set'
            ;;
        f|find) directory_action='find' ;;
        ffs|find-files-set) 
            directory_action='find-files'
            file_action='set'
            ;;
        ff|find-files) directory_action='find-files' ;;
        fds|find-dirs-set) 
            directory_action='find-dirs'
            file_action='set'
            ;;
        fd|find-dirs) directory_action='find-dirs' ;;
        l|list) directory_action='list';;
        ls|lists) 
            directory_action='list'
            file_action='set'
            ;;
        lfs|list-files-set) 
            directory_action='list-files'
            file_action='set'
            ;;
        lf|list-files) directory_action='list-files' ;;
        lds|list-dirs-set) 
            directory_action='list-dirs' 
            file_action='set'
            ;;
        ld|list-dirs) directory_action='list-dirs' ;;
        l*) die "Err: invalid list action" ;;
        copy|cat|get|print|run|edit|golf|degolf|shfunc|alias)
            [ -n "$file_action" ] && die "Err: file action '$file_action' already set"
            file_action="$1"
            ;;
        new)
            [ -n "$file_action" ] && die "Err: file action '$file_action' already set"
            file_action="$1"
            check_existing=0
            ;;
        reset)
            rm -f "$state_dir"/*
            echo "Ok $state_dir resettet"
            exit
            ;;
        *) die "Err: invalid item action" ;;
    esac
    [ -n "$directory_action" ] && break
    [ -n "$file_action" ] && break
    shift
done



if [ -z "$file_action" ] ; then
    [ -z "$directory_action" ] && die "no action input and no directory_action, usage: $USAGE"
fi

shift

post_actions(){
    while [ $# -gt 0 ] ; do
        case "${1:-}" in
            *) : ;;
        esac
        pop
    done
}

for post_arg do
  shift
  case $post_arg in
    -set|-s) 
        [ -n "$file_action" ] && die "Err: cannot set, already file action" 
        file_action=set
        ;;
    -copy|-c) 
        [ -n "$file_action" ] && die "Err: cannot set, already file action" 
        file_action=copy
        ;;
       *) set -- "$@" "$post_arg" ;;
  esac
done


loader(){

    local script
    case $# in
        2)
            local dir="${1}"
            [ -d "$dir" ] || die "Err: dir invalid $dir"
            local name="${2}"
            [ -n "$name" ] || die "Err: name empty"
            script="$dir/$name.sh"
            ;;
        1) script="$1" ;;
        *) die "Err: loader - not enough args" ;;
    esac

    if [ -f "$script" ] ; then
        . "$script"
    else
        die "Err: cannot find and load '$script'"
    fi
}

item_from_owl_list='item_from_owl_list__jUAWAzpA'
loader  "$homekit/functions" "$item_from_owl_list"

findfiles_owl_list='findfiles_owl_list__QKaRaY2A'
loader "$homekit/functions" "$findfiles_owl_list" 

getpath='getpath__hw6g6NRX'
loader "$homekit/functions" "$getpath" 

lib_plx="$homekit/tools/act/lib_plx.sh"
loader "$lib_plx"




get_statefile(){
    local state_file="$(ls -Ar  "$state_dir"/ | head -n1)"
    if [ -n "$state_file" ] ; then
        local state_file_path="$state_dir/$state_file"
        [ -f "$state_file_path" ] || die "Err: xno valid state file $state_path"
        echo "$state_file_path"
    fi
}


directory_actions(){
    local action="${1:-}"
    [ -n "$action" ] || die "Err: no action"

    local working_dir="${2:-}"
    [ -n "$working_dir" ] || die "Err: no working dir"
    [ -d "$working_dir" ] || die "Err: invalid working dir $working_dir"
    
    local file_list
    case "$action" in
        list) file_list="$(${findfiles_owl_list}  -min=0 -ext="$file_ext" -args="-maxdepth 0 "  "$working_dir")" ;;
        list-files) file_list="$(${findfiles_owl_list}  -min=0 -ext="$file_ext" -args="-maxdepth 0 -type f"  "$working_dir")" ;;
        list-dirs) file_list="$(${findfiles_owl_list}  -min=0 -ext="$file_ext" -args="-maxdepth 0 -type d"  "$working_dir")" ;;
        find) file_list="$(${findfiles_owl_list}  -min=1 -ext="$file_ext" -args=" "  "$working_dir")" ;;
        find-files) file_list="$(${findfiles_owl_list}  -min=1 -ext="$file_ext" -args=" -type f"  "$working_dir")" ;;
        *) die "Err: unknown list action $directory_action" ;;
    esac

    if [ -n "$file_list" ]; then
        echo "$file_list"
    else
        die "Err: no file_list"
    fi
}



set_stampfile(){
    local file_path="${1:-}"
    [ -n "$file_path" ] || die "Err: no file path"

    stamp="$(date +'%Y%m%d%H%M%S')"
    [ -n "$stamp" ] || die "Err: no stamp"
    stampfile="$state_dir/$stamp"
    if [ -f "$stampfile" ] ; then
        for i in $(seq 1 3); do 
            sleep 1
            [ -f "$state_dir/$stamp" ] || stampfile="$state_dir/$stamp"
        done
    fi
    [ -f "$stampfile" ] && die "Err: stampfile already exists $stampfile"
    echo "$file_path" > "$stampfile"
    echo "OK: filepath '$file_path' set into: $stampfile" >&2
}


######################################
base_input="${1:-}"

working_item=
if [ -n "$base_input" ] ; then 
    base_item=
    case "$base_input" in
        .) base_item="$PWD" ;;
        *) base_item="$base_input" ;;
    esac
    shift

    token_input="${1:-}"
    if [ -n "$token_input" ]; then
        case "$token_input" in
            *:*) 
                [ -n "$file_ext" ] && die "Err: file extension already set"
                file_ext="${token_input##*:}" 
                working_item="$base_item/${token_input%:*}"
                ;;
            *) working_item="$base_item/${token_input}" ;;
        esac
        shift
    else
        working_item="$base_item"
    fi
fi


file_list=
working_dir=
# first if diract, list stuff
if [ -n "$directory_action" ] ; then
    if [ -n "$working_item" ] ; then
        working_dir="$working_item"
    else
        working_dir="$PWD"
    fi
    [ -d "$working_dir" ] || die "Err: working_dir is not a valid directory : $working_dir"
    file_list="$(directory_actions "$directory_action" "$working_dir")" || die "Err: could not get file_list"
    [ -d "$state_dir" ] && rm -f "$state_dir"/*
else
    directory_action='find'
fi

# exit if no itemact
if [ -z "$file_action" ] ; then
    if [ -n "$file_list" ]; then 
        ${item_from_owl_list} list "$file_list" $@
    else
        warn "Sorry could not get list"
    fi

    exit
fi

working_file=
state_file_path=
# is there a state file if no inputs
if [ -z "$file_list" ] ; then
    if [ -z "$working_item" ] ; then  # no input, check for statefile
        state_file_path="$(get_statefile)" || die "Err: cannot get state file"
        if [ -n "$state_file_path" ] ; then
            if [ -n "$state_file_path" ] ; then
                warn "info: stampfile: $state_file_path"
                warn '----'
            fi
            working_file="$(cat "$state_file_path")" || die "Err: cannot cat"
        else
            [ -n "$working_dir" ] || working_dir="$PWD"
        fi
    else
        [ -n "$working_dir" ] || working_dir="$working_item"
    fi

fi

# is there a token, that could be a file
if [ -z "$file_list" ] && [ -z "$working_file" ] ; then
    if [ -f "$working_item" ] ; then
        working_file="$working_item"
    elif [ -d "$working_item" ] ; then
        working_dir="$working_item"
    fi
fi

# try to show a selection
if [ -z "$file_list" ] && [ -z "$working_file" ] ; then
    [ -n "$working_dir" ] || working_dir="$PWD"
    file_list="$(directory_actions "$directory_action" "$working_dir")" || die "Err: could not get file_list"
    [ -n "$file_list" ] || die "Sorry: could not get file list"
    file_result="$(${item_from_owl_list}  choose "$file_list" $@)"
    [ -n "$file_result" ] || die "Err: no file result"
    working_file="$(${getpath} -check="$check_existing" "$working_dir"  "${file_result}" "$file_ext")" || die "Err: could not get working_file"
fi

if [ -n "$working_file" ] ; then
    if [ $check_existing -gt 0 ] ; then
        [ -f "$working_file" ] || die "Err: file '$working_file' not exists"
    fi
else
    die "Err: could not get working file"
fi



case "$file_action" in
    copy) 
        printf "%s"  "$working_file" | pbcopy
        set_stampfile "$working_file"
        ;;
    get) 
        [ -n "$state_file_path" ] || die "Err: no state_file_path"
        cat "$state_file_path"
        ;;
    print) 
        [ -n "$working_file" ] || die "Err: nothing to print"
        echo "$working_file"
        ;;
    cat) 
        [ -n "$working_file" ] || die "Err: nothing to print"
        warn "File: $working_file"
        warn '-----'
        cat "$working_file"
        ;;
    set) set_stampfile "$working_file" ;;
    edit) 
        echo "$working_file"
        echo '----'
        read -p "edit? [Y|n]" doedit
       case "$doedit" in
            n|N) 
                warn "bye" 
                exit 
                ;;
            *) : ;;
        esac
        vim "$working_file"
        ;;
    new)
        filedir="$(dirname "$working_file")"
        if [ -e "$filedir" ]; then
            [ -d "$filedir" ] || die "Err: '$filedir' is not a dir"
        else
            mkdir -p "$filedir"
        fi
        touch "$working_file"
        echo "$working_file"
        ;;
    shfunc)
        plxcmd="$(get_plxcmd "$working_file")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        plxbasename="$(basename "$working_file")"
        plxname="${plxbasename%.*}"

        echo "$plxname(){"
            echo "   # $plxbasename:"
            printf "   %s -e '" "$plxcmd"
            perl -w -n "$selfdir/plx-golf.plx" "$working_file"
            echo "' "' "$@"'
        echo '}'
        ;;
    alias)
        [ -f "$working_file" ] || die "Err: working_file '$working_file'  not valid"
        plxcmd="$(get_plxcmd "$working_file")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        plxbasename="$(basename "$working_file")"
        plxname="${plxbasename%.*}"

        printf "alias %s='%s -e '" "$plxname" "$plxcmd"
        perl -w -n "$selfdir/plx-golf.plx" "$working_file"
        echo "' "
        ;;
    golf)
        [ -f "$working_file" ] || die "Err: working_file '$working_file'  not valid"
        perl -w -n "$selfdir/plx-golf.plx" "$working_file"
        ;;
    degolf)
        [ -f "$working_file" ] || die "Err: working_file '$working_file'  not valid"
        [ $# -gt 0 ] || die "Err: too few args"
        perl -w -n "$selfdir/plx-degolf.plx" "$@"
        ;;
    run)
        [ -f "$working_file" ] || die "Err: working_file '$working_file'  not valid"

        plxcmd="$(get_plxcmd "$working_file")" || die "Err: could not get plxcmd"
        [ -z "$plxcmd" ]  && die "Err: could not get plxcmd"

        ${plxcmd} "$working_file" "$@"
        ;;
    *)
        die "Err: invalic file_action $file_action"
        ;;
esac

