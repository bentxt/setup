
#store a list of files '#@;@#' ("owl") separated, relative pathes
#
die(){ 
    echo "$*" >&2
    exit 1
}

findfiles_owl_list__QKaRaY2A(){

    local USAGE='[-abs] [-min=mindepth] [-ext=file-extension]  [-args=<find-args>] <listdir> <filter>'

    local file_ext=
    local mindepth=
    local find_args=
    local opt_abspath=

    while [ $# -gt 0 ] ; do
        case "${1:-}" in
            -h|--help|h|help) die "usage: $USAGE" ;; 
            -abs) opt_abspath=1;;
            -min=*) mindepth="${1#*=}" ;;
            -ext=*) file_ext="${1#*=}" ;;
            -args=*) find_args="${1#*=}" ;;
            -*) die "Err: invalid option $1";;
            *) break ;;
        esac
        shift
    done


    [ -z "$mindepth" ] && mindepth=1

    local find_dir="${1:-}"
    [ -n "$find_dir" ] || die "no find_dir, usage: $USAGE"
    [ -d "$find_dir" ] || die "Err: invalid find_dir"
    shift

    local filter="${1:-}"

    if [ -n "$file_ext" ] ;then
        case "$file_ext" in
            .*) : ;;
            *) file_ext=".$file_ext" ;;
        esac
        shift
    fi

    if [ -n "$opt_abspath" ] ; then
        find "$find_dir"  -mindepth "$mindepth"  $find_args -iname "*$filter*$file_ext" -print0 | perl -0 -n -e 'print("$_" .  "#@;@#")' 
    else
        cd "$find_dir"
#        echo find '.' -mindepth "$mindepth"  $find_args -iname "*$filter*$file_ext" -print0 >&2 
        find '.' -mindepth "$mindepth"  $find_args -iname "*$filter*$file_ext" -print0 | perl -0 -n -e 'print("$_" .  "#@;@#")' 
    fi
}

