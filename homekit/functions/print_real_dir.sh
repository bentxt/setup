#!/bin/sh
#
# jump to the dir hosting an item
# command
#
USAGE='[input]'

input="${1:-}"

set -eu

[ -z ${DEBUG+x} ] && DEBUG=

prn() { printf "%s" "$@"; }
fail() { echo "Fail: $*" >&2; }
warn() { echo "Warn: $*" >&2; }
info() { echo "$@" >&2; }
die() {
    echo "$@" >&2
    exit 1
}

stamp() { date +'%Y%m%d%H%M%S'; }
absdir() (cd "${1}" && pwd -P)
abspath() { perl -MCwd=abs_path -e 'print abs_path($ARGV[0]);' "$1"; }
getos() { uname | tr '[:upper:]' '[:lower:]'; }
getlines() {  wc -l < "${1:-}" | tr -d ' ' ; }
getnewfile(){ case "$1" in */*) prn "${1%/*}/$2" ;; *) prn "$2" ;; esac; }
getnewfilext(){ getnewfile "$1" "$(basename "$1" "${1##*.}")$2" ; }

[ -n "$input" ] || die "usage: $USAGE"
[ -e "$input" ] || die "Err: input '$input' not exists"

realpath="$(readlink -f "$input")"

if [ -L "$realpath" ] ; then
    die "Err: still a symbolic link '$realpath'"
elif [ -d "$input" ] ; then
    prn "$realpath"
elif [ -f "$input" ] ; then
    dirname "$realpath"
else
    die "Err: this path is not supported"
fi

