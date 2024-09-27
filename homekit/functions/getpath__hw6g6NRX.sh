
set -u

die(){
    echo "$*" >&2
    exit 1
}

getpath__hw6g6NRX(){
    local USAGE='-c|--check-existing <0|1>  <basedir> <input_file> <ext>'
            

    local opt_check_existing=
    while [ $# -gt 0 ] ; do
        case "$1" in
            -help) die "usage: $USAGE" ;;
            -check=*) 
                opt_check_existing="${1##*=}"
                [ -n "$opt_check_existing" ] || die "Err: non-existing, arg missing"
                ;;
            -*) die "Err: invalid opt" ;;
            *) break ;;
        esac
        shift
    done

    local input_basedir="${1:-}"
    [ -n "$input_basedir" ] || die "Err: n o baasedir, arg missing"
    [ -d "$input_basedir" ] || die "Err: invaliid baasedir, $input_basedir"
    shift

    local input_file="${1:-}"
    [ -n "$input_file" ] || die "no input_file, usage '$USAGE'"
    shift

    local input_ext="${1:-}"

    if [ -n "$input_basedir" ] ; then
        [ -d "$input_basedir" ] || die "no valid basedir"
    else
        input_basedir='.'
    fi

    local input_file_base
    input_file_base="$(basename "$input_file")"

    if [ -n "$input_ext" ] ; then
        input_file_ext="${input_file_base##*.}"

        case "$input_ext" in
            ".$input_file_ext") : ;;
            "$input_file_ext")  : ;;
            *) die "Err: file extension not matching ($input_ext vs $input_file_ext)" ;;
        esac
    fi

    local filepath=
    case "$input_file" in
        /*${input_file}|.*${input_file})  filepath="$input_file" ;;
        */*${input_file})  
            input_file_dir="$(dirname "$input_file")"
            file_dir="$input_basedir/$input_file_dir"
            mkdir -p "$file_dir" || die "Err: could not create dir $file_dir"
            filepath="$file_dir/$input_file_base"
            ;;
        $input_file) filepath="$input_basedir/$input_file" ;;
        
        *) die "Err: is not looking like a plx file $input_file" ;;
    esac

    if [ -f "$filepath" ] ; then
        printf "%s" "$filepath"
    else
        if [ -n "$opt_check_existing" ] ; then
            if [ $opt_check_existing -eq 0 ] ;then
                printf "%s" "$filepath"
            else
                die "Err: no valid filepath $filepath found"
            fi
        else
            die "Err: no valid filepath $filepath found"
        fi
    fi

}
