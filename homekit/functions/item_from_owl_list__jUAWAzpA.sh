
set -u

die(){
    echo "$*" >&2
    exit 1
}

item_from_owl_list__jUAWAzpA(){

    local USAGE='[list|choose] <owl separated list> [filters] ....'

    local action="${1:-}"
    [ -n "$action" ] || die "Sorry: no action"
    shift

    local list_input="${1:-}"
    [ -n "$list_input" ] || die "Sorry: no list_input"
    shift

    local list_filtered=
    if [ $# -gt 0 ] ; then
        list_filtered="$(perl -MList::Util'=all' -e '$l=shift; @f=split("#@;@#", $l); print(join("#@;@#", grep {$v=$_; all { $v =~ /$_/ } @ARGV} @f)) ;' "$list_input" $@)"
    else
        list_filtered="$list_input"
    fi


    [ -n "$list_filtered" ] || die "Err: could not filter list"

    case "$list_filtered" in
        *'#@;@#'*)
            case "$action" in
                list)
                    perl -l -e  'map { print($_)} split("#@;@#", $ARGV[0]);' "$list_filtered"
                    ;;
                choose)
                    perl -l -e ' map { print(STDERR ++$i . ": $_") }  split("#@;@#", $ARGV[0]); ' "$list_filtered"
                    read -p "Enter number: " number
                    [ -n "$number" ] || die "Err: no number"
                    case $number in
                        ''|*[!0-9]*) die "Err: sorry number $number is not a number" ;;
                        *) : ;; 
                    esac
                    perl -l -e  ' @l=split("#@;@#", $ARGV[0]); print($l[$ARGV[1] - 1]); ' "$list_filtered" "$number" || die "Err: getitem failed"
            ;;
                *) die "Err: invalid action '$action'" ;;
            esac
            ;;
        *)
            echo "$list_filtered" 
        ;;
    esac
}
