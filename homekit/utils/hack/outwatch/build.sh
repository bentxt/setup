

set -u

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
getos() { uname | tr '[:upper:]' '[:lower:]'; }


perl $1
