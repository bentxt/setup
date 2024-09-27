# todos around bkblib, loading libraries etc
#
libpath(){
    local lib="${1:-}"; local pkg="${2:-}"; local version="${3:-}"
    local lib_str
    case $# in 3) lib_str="$pkg/${lib%.*}/${lib%.*}_${version}.${lib##*.}" ;; 2) lib_str="$pkg/${lib}";; 1) lib_str="${lib}";; esac
    if [ -z "$lib_str" ]; then
        fail  "(libpath): could not set lib_str, wron number of args"
        return 1
    fi
    local lib_path
    for dir in "${MAINDIR:-}" ${BKB_LIBRARY_PATH:-} "$HOME/.local/bkblib"; do
        if [ -f "$dir/$lib_str" ]; then lib_path="$dir/$lib_str";  BKB_LIBS="${lib},${lib_str} ${BKB_LIBS:-}"; break ; fi
    done
    [ -f "${lib_path:-}" ] || {
        fail "(libpath): could not find lib for '$lib'" 
        return 1
    }
    prn "${lib_path}"
}

loadlib(){ # for foolib.sh modulino.dash 
    local lib="${1:-}";
    case "${lib:-}" in *lib.sh|*.dash) : ;; *) fail "loadlib: not a valid lib '${lib:-}'"; return 1 ;; esac
    local lib_str
    for l in ${BKB_LIBS:-}; do 
        if [ "${l%,*}" = "$lib" ]; then
            if [ "${l##*,}" = "$lib_str" ]; then  return 0; else info "Warn: lib '$lib' loaded,  '$lib_str' not loaded"; return 1; fi
        fi
    done
    local lib_path; lib_path="$(libpath "$@")" || { fail "loudlib: library not loaded '$lib'" ; return 1; }
    . "$lib_path" || { fail "loadlib: could not load '$lib_path'" ; return 1; }
}


