#!/bin/sh
#
# NAME
#
#   ssh-permissions - fix/set permissions 
#
# DESCRIPTION
#
#   Fix and set permissions of ~/.ssh and of ssh keys (public/private)
#
#   If a directory is given  it handles the keys inside
#
#   SSH folder:     ~/.ssh              700     drwx------
#   Public key:     ~/.ssh/id_rsa.pub	644	    -rw-r--r--
#   Private key:    ~/.ssh/id_rsa       600     -rw-------
#   Home folder:    ~	                755 at most	drwxr-xr-x at most
#
# SYNOPSIS
#
#   ssh-permissions [directory], or run with --help
#
# OPTIONS
#
#   --help          show help
#

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
getos() { uname | tr '[:upper:]' '[:lower:]'; }


ssh_permissions__keys(){
    local sshdir="${1:-}"
    if ! [ -d "$sshdir" ] ; then
        fail "no valid sshdir under '$sshdir'"
        return 1
    fi

    # 0644
    #
    [ -f "$sshdir/config" ] && chmod 0644 "$sshdir/config"

    for pubkey in "$sshdir"/*.pub ; do
        [ -f "$pubkey" ] || continue

        chmod 0644 "$pubkey"

        bname="${pubkey##*/}"
        privkey="${bname%.*}"

        # 0600

        if [ -f "$sshdir/$privkey" ] ; then
            chmod 0600 "$sshdir/$privkey"
        else
            info "could not find privkey '$sshdir/$privkey'"
        fi
    done

    # 0600

    for file in "$sshdir/authorized_keys" "$sshdir/known_hosts" ; do
        [ -f "$file" ] || continue
        chmod 0600 "$file"
    done
}

main() {

    if [ $# -eq -1 ] ; then
        info "not enough args"
        perl -ne 's/^#+\s*//g; die "usage: $_" if($_ && $s); $s=1 if (/^SYNOPSIS\s*$/);' "$0" >&2
        exit 1
    fi

    local sshdir=
    while [ $# -gt 0 ]; do
        case "${1:-}" in
            -h | --help)
                perl -ne 'print "$1\n" if /^\s*#\s(.*)/; exit if /^\s*[^#\s]+/;' "$0" >&2
                exit 1
            ;;
            *)
                sshdir="$1"
                shift
                break ;;
        esac
        shift
    done


    if [ -d "$HOME/.ssh" ] ; then
        chmod 0700 "$HOME/.ssh"
        ssh_permissions__keys "$HOME/.ssh"
    fi

    if [ -n "$sshdir" ] ; then
        ssh_permissions__keys "$sshdir"
    fi

}


if [ -t 0 ]; then
    main "$@" || die 'Abort utils_template__main ...'
else
    die 'Err: run program interactively'
fi
