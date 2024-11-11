#!/bin/sh



# preprocessor for the clue compiler
# https://github.com/ClueLang/Clue
# Options:
#   -d debug
#   -a amalgation

set -u 

info_switch=1

die (){ echo "$*"  1>&2 ; exit 1; }

info(){ [ -n "$info_switch" ] &&    echo "$*" 1>&2 ; }

opt_debug=
opt_amalgation=
while [ $# -gt 0 ] ; do
    case "${1}" in
        -d) opt_debug=1 ;;
        -a) opt_amalgation=1 ;;
        -*) die "Err: invalid arg '$1'";;
        *) break ;;
    esac
    shift
done


indir=
infile=
if [ -n "${1:-}" ] ; then
    if [ -f "$1" ] ; then
        if [ -n "$opt_amalgation" ] ; then
            die "Err: amalgation is only for directories"
        fi
        case "$1" in
            out.clue)  die "Err: invalid input file" ;;
            *.clue) 
                infile="$1" 
                shift
                ;;
            *) die "Err invalid input " ;;
        esac
        indir="$(dirname "$infile")"
    else
        indir="$1"
    fi
else
    indir="$(pwd)"
fi

outdir=
if [ -n "${2:-}" ] ; then
    outdir="$2"
else
    outdir="$indir/out"
fi


if [ -n "$opt_debug" ] ; then
    [ -n "$infile" ] || outdir="$outdir/debug"
else
    [ -n "$infile" ] || outdir="$outdir/release"
fi

if [ -n "$opt_amalgation" ] ; then
    [ -f "out.clue" ] && die "Err: out.clue is reserved"
fi


plx_clue='/^Compiled (Lua|file).*(:|!)$/ || print' 
if [ -n "$opt_amalgation" ] ; then
    plx_clue="$plx_clue;"'/^static\b/ && die "Err: please no static keyword"' 
fi

write_luamodule(){
    local cluefile="${1:-}"
    [ -n "$cluefile" ] || die "Err: no file given"
    [ -f "$cluefile" ] || die "Err: no file given under $cluefile"

    local luafile="${2:-}"
    [ -n "$luafile" ] || die "Err: no luafile given"

    if [ -n "$opt_debug" ] ; then
        {
            echo 'local _M = {}'
            clue -d -o "$cluefile" |  perl -n -e "$plx_clue" || die "Err: clue failed"
            echo 'return _M'
        } > "$luafile"
    else
        {
            echo 'local _M = {}'
            clue -o "$cluefile" | perl -n -e "$plx_clue" || die "Err: clue failed"
            echo 'return _M'
        } > "$luafile"
    fi

    echo "written to '$luafile'"

}


write_cluefile(){
    local clue_in="${1:-}"
    [ -n "$clue_in" ] || die "Err: no file given"
    [ -f "$clue_in" ] || die "Err: no file given under $clue_in"
    local clue_out="${2:-}"
    [ -n "$clue_out" ] || die "Err: no clue_out given"

    perl -p -e 's/^\s*module\s+fn\s+(\w+)\(/method _M.$1(/g' "$clue_in" > "$clue_out" || die "Err: could not write to file"

}

mkdir -p "$outdir"


if [ -n "$infile" ] ; then

    rm -rf "$outdir"/*

    infile_basename="$(basename "$infile")"

    infile_name="${infile_basename%.*}"
    outfile="$outdir/$infile_name.clue"

    write_cluefile "$infile" "$outfile"

else

    for f in $indir/*.clue; do
        [ -f "$f" ] || continue

        bf="${f##*/}"
        name="${bf%.*}"
        [ -n "$name" ] || die "Err: no name for '$bf'"

        clue_out="$outdir/$name.clue"
        if [ -f "$clue_out" ] ; then
            if [ "$f" -nt "$clue_out" ] ; then
                write_cluefile "$f" "$clue_out"
            else
                info "use cache from '$clue_out'"
            fi
        else
            write_cluefile "$f" "$clue_out"
        fi
    done

    # produces a main.lua outside of out
    if [ -n "$opt_amalgation" ] ; then
        if [ -n "$opt_debug" ] ; then
            clue -d "$outdir" || die "Err: clue failed"
        else
            clue "$outdir" || die "Err: clue failed"
        fi

        # produces out.lua
        perl -n -e 'if(/^\s*_modules = \{\s$/){ print; exit}else{print}' "main.lua" > out.lua || die "Err: perl liner failed"
    fi

fi


for f in "$outdir"/*.clue; do
    [ -f "$f" ] || continue

    bf="${f##*/}"
    name="${bf%.*}"

    [ -n "$name" ] || die "Err: noname for $bf"

    lua_out="$outdir/$name.lua"

    if [ -f "$lua_out" ] ; then
        if [ "$f" -nt "$lua_out" ] ; then
            write_luamodule "$f" "$lua_out"
        else
            info "use cache from $lua_out"
        fi
    else
        write_luamodule "$f" "$lua_out"
    fi
    
    [ -f "$lua_out" ] || die "Err: still no lua file in '$lua_out'" 

    if [ -n "$opt_amalgation" ] ; then
        {
            echo "    ['$name'] = function(...)"
            cat "$lua_out"
            echo '    end,'
        } >>  out.lua
    fi
done


if [ -n "$opt_amalgation" ] ; then
    {
        echo '}'
        echo 'if _modules["main"] then'
        echo '   return import("main")'
        echo 'else'
        echo '    error("File \"main.clue\" was not found!")'
        echo 'end'
    } >> out.lua

    if [ -n "$opt_debug" ]; then
        {
            echo 'end)'

            echo 'if not ok then'
            echo '  _errored_file = "main.clue"'
            echo '_clue_error(err)'
            echo '    error(_errored)'
            echo ' end'
        } >> out.lua
    fi

    echo "written to 'out.lua'"
fi


