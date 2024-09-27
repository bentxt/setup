

selfdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

rm -f "$HOME/kit"
ln -s "$selfdir" "$HOME/kit"

selfname="$(basename "$selfdir")"

if [ -n "${1:-}" ] ; then
    rm -f "$1/$selfname"
    ln -s "$selfdir" "$1/$selfname"
fi


