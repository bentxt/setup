
set -u


# -prefix <spaced-list> <postfixes> ...
colonize_list(){


    local prefix=''
    local spaced_list=''

    while [ $# -gt 0 ] ; do
        case "$1" in
            -prefix) 
                if [ -n "${2:-}" ] ; then
                    prefix="$2/"
                    shift
                else
                    echo "Err: could not set prefix"
                    return 1
                fi
                ;;
            -*)
                echo "Err: invalid opt $1"
                return 1
                ;;
            *)
                spaced_list="$1"
                shift 
                break
                ;;
        esac
        shift
    done

    [ -z "${spaced_list+x}" ] && die "Err: no spaced list given"

    local env_var=
    if [ -z ${1+x} ]; then
        die "Err: env var is unset"
    else
        env_var="$1"
    fi

    local postfix_prefix
    if [ -n "$prefix" ] ; then
        postfix_prefix="$prefix"
    else
        postfix_prefix='/'
    fi

    local list
    for pf in $@ ; do
        [ -n "$pf" ] || continue
        [ -d "${postfix_prefix}${pf}" ] || continue
        if [ -n "$list" ] ; then
            list="${postfix_prefix}${pf}:$list"
        else
            list="${postfix_prefix}$pf"
        fi
    done


    local fulldir 
    for dir in $spaced_list; do
        [ -n "$dir" ] || continue
        case "$dir" in
            */) dir="${dir%?}";;
            *) : ;;
        esac

        fulldir=''
        if [ $# -eq 0 ] ; then
            if [ -d "${prefix}${dir}" ] ; then
                if [ -n "$list" ] ; then
                    list="${prefix}${dir}:$list"
                else
                    list="$dir"
                fi
            fi
        else
            for pf in $@ ; do
                [ -n "$pf" ] || continue
                if [ -d "${prefix}${dir}/$pf" ] ; then
                    if [ -n "$list" ] ; then
                        list="${prefix}${dir}/$pf:$list"
                    else
                        list="${prefix}${dir}/$pf"
                    fi
                fi
            done
        fi
    done

    echo "$list"
}


# bash utils.bash brew-prefix-path 'PATH' 'openssl' 'lib'
brew_prefix_path(){
    local prefix="${1:-}"
    
    local sub_dir="${2:-}"


    command -v brew >/dev/null  || return 

    local brew_prefix="$(brew --prefix $prefix)"
    [ -n "$brew_prefix" ] || continue
    [ -d "$brew_prefix" ] || continue

    local prefix_dir
    if [ -n "$sub_dir" ]; then
        prefix_dir="$brew_prefix/$sub_dir" 
    else
        prefix_dir="$brew_prefix"
    fi
    case "$prefix_dir" in
        */) prefix_dir="${prefix_dir%?}";;
        *) : ;;
    esac

    [ -d "$prefix_dir" ] || return  

    echo "$prefix_dir"
}




CMD="${1:-}"
[ -n "$CMD" ] || die "Err: no CMD given"
shift


case "$CMD" in
    read-hostvars) read_hostvars "$@" ;;
    colonize-list) colonize_list "$@" ;;
    brew-prefix-path) brew_prefix_path "$@" ;;
    merge-colonlists) merge_colonlists "$@" ;;
    *) die "Err: invalid cmd $CMD" ;;
esac
