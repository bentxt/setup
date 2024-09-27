#!/bin/sh
#
# NAME
#
#   unpack -  Unpack files
#
# DESCRIPTION
#
#   Decompress a number of files
#
#   tar, gz, tgz, bz2, xz, tbz2
#   tar, lzma, bz2, rar, gz , zip, .Z, .7z, xz, exe
#
#   Can also read from STDIN as part of a pipe
#
#   ls | unpack
#
# 
#
# SYNOPSIS
#
#   unpack  [OPTIONS] [file ... ], or run with --help
#
# OPTIONS
#
#   -d|--dir <directory>    Instead of a file use directory as input
#
#

set -eu

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
info() { echo "$@" >&2; }
die() {
	echo "$@" >&2
	exit 1
}

secstamp() { date +'%Y%m%d%H%M%S'; }
absdir() (cd "${1}" && pwd -P)


utils_unpack__file(){
    local input_file="${1:-}"
    if [ -z "$input_file" ] || ! [ -f "$input_file" ] ; then
        fail "invalid input file under '$input_file'"
        return 1
    fi

    local input_base="${input_file##*/}"
    local input_ext="${input_base##*.}"

    local input_dir=
    input_dir="$(dirname "$input_file")"


    case "$input_base" in
    *.tar.*)
        local tar_opt=
        case "$input_ext" in
            tar) tar_opt=xvf ;;
            gz) tar_opt=xvzf ;;
            tgz) tar_opt=xvzf ;;
            bz2) tar_opt=xvjf ;;
            xz) tar_opt=xvJf ;;
            tbz2) tar_opt=xvjf ;;
        *) die "Err: invalid tar extension '$input_ext'" ;;
        esac
        local input_name_dot="${input_base%.*}"
        local input_name="${input_name_dot%.*}"
        if [ -d "$input_dir/$input_name" ] ; then
            fail "directory '$input_dir/$input_name' already exists"
            return 1
        fi
        tar $tar_opt "$input_file"
        ;;
    *)
        local input_name="${input_base%.*}"
        if [ -d "$input_dir/$input_name" ] ; then
            fail "directory '$input_dir/$input_name' already exists"
            return 1
        fi

        case "$input_ext" in
            tgz) tar -xvf "$input_file" ;;
            tar) tar xvf "$input_file" ;;
            lzma) unlzma "$input_file" ;;
            bz2) bunzip2 "$input_file" ;;
            rar) unrar x -ad "$input_file" ;;
            gz) gunzip "$input_file" ;;
            zip) unzip "$input_file" ;;
            Z) uncompress "$input_file" ;;
            7z) 7z x "$input_file" ;;
            xz) unxz "$input_file" ;;
            exe) cabextract "$input_file" ;;
            *) echo "skip: '$input_ext' - unknown archive method" ;;
        esac
    ;;
    esac
}



utils_unpack__run() {

    local opt_dir=
    while [ $# -gt 0 ]; do
        case "$1" in
        -d|--dir)
            opt_dir="${2:-}"
            if [ -n "$opt_dir" ] ; then
                shift
            else
                fail "argument missing of -d|--dir"
                return 1
            fi
            ;;
        -*)
            info "invalid arg '$1', run --help"
            return 1
            ;;
        *) break ;;
        esac
        shift
    done


    if [ -t 0 ]; then
        if [ -n "$opt_dir" ] ; then
            [ -d "$opt_dir" ] || {
                fail "dir is invalid '$dir'"
                return 1
            }
            for file in "$opt_dir"/* ; do
                echo ffff $file
                if [ -f "$file" ]; then
                    utils_unpack__file "$file"
                else
                    info "skip invalid file '$file'"
                fi
            done

        else
            for file in "$@" ; do
                if [ -f "$file" ] ; then 
                    utils_unpack__file "$file"
                else
                    info "skip invalid file '$file'"
                fi
            done
        fi
    else
        if [ -n "$opt_dir" ] ; then
            fail "not opt_dir when reading from stdin"
            return 1
        fi

        while read -r file ; do
            if [ -f "$file" ] ; then 
                utils_unpack__file "$file"
            else
                info "skip invalid file '$file'"
            fi
        done
    fi
}
utils_unpack__main() {

    if [ $# -eq 0 ] ; then
        info "not enough args"
        perl -ne 's/^#+\s*//g; die "usage: $_" if($_ && $s); $s=1 if (/^SYNOPSIS\s*$/);' "$0" >&2
        exit 1
    fi

    while [ $# -gt 0 ]; do
        case "${1:-}" in
            -h | --help)
                perl -ne 'print "$1\n" if /^\s*#\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
                exit 1
            ;;
            *) break ;;
        esac
        shift
    done
}


#### Modulino

if [ -z "${MAINSCRIPT:-}" ]; then
    MAINSCRIPT="$(absdir "$(dirname "$0")")"
    if [ -t 0 ]; then
        utils_unpack__main "$@" || die 'Abort main ...'
    else
        die "Err: must be use interactively ..."
    fi
    utils_unpack__run "$@" || die 'Abort run ...'
fi
