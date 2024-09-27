
# perl -n 
#

set -u

die(){
    echo "$@" >&2
    exit 1
}

libplx__get_plxcmd(){
    local plxfile="${1:-}"
    [ -n "$plxfile" ]  || die  "Err: no plx file"
    [ -f "$plxfile" ]  || die  "Err: no valid plx file"

    local plxcmd
    # catches the perl shebang on the first line, even when not starting with #!
    plxcmd="$(perl -n -e 'if(/^\s*\#+\s*\!?\s*(.+)$/){$m=$1; if($1=~/^perl/){ print($m); exit; }else{exit}}' "$plxfile")"

    if [ -n "$plxcmd" ] ; then
        echo "$plxcmd"
    else
        echo 'perl -w -n '
    fi
}

libplx__get_plxcmd "$@"
