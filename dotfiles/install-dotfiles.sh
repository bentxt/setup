#/bin/sh
#
#
# a dash in the file is the same as a folder
# fish-config.fish = fish/config.fish
#
#   handle dirs
#   and files like *profile *rc
#
set -u

## 

die () { echo "$@" >&2; exit 1; }
info () { echo "$@" >&2;  }
absdir() {
    if [ -f "${1:-}" ] ; then (cd  "$(dirname -- "${1}" 2>/dev/null)";  pwd -P)
    else (cd "${1:-$PWD}" >/dev/null; pwd -P)
    fi
}

LINKDIR="${1:-}"

##

SCRIPTNAME="${0##*/}"
SCRIPTDIR="$(absdir "$0")"


PWDNAME="${PWD##*/}"
PWDPATH="$(absdir "${PWD}")"

if [ -n "$LINKDIR" ] ; then
    rm -f "$LINKDIR/$PWDNAME"
    ln -s "$PWDPATH" "$LINKDIR/$PWDNAME"
fi

##

LIBUTIL="$SCRIPTDIR"/'libutil.sh'
if [ -f "$LIBUTIL" ] ; then
    . "$LIBUTIL"  || die "Err: could not load libutil under '$LIBUTIL'";
else
    die "Err: could not load libutil under '$LIBUTIL'"
fi

install_to_linkdir(){
    if [ -d "$LINKDIR" ] ; then
        local i="${1:-}"
        local bi="${2:-}"


        rm -f "$LINKDIR/$bi"
        ln -s "$i" "$LINKDIR/$bi"
        rm -f "$LINKDIR/.$bi"
        ln -s "$i" "$LINKDIR/.$bi"
    fi
}


create_parent_dir(){
    local dir="${1:-}"
    [ -n "$dir" ] || die "Err: no target_item"

    local parent_dir="$(dirname "$dir")"

    if [ -e "$parent_dir" ] ; then
        [ -d "$parent_dir" ] || die "Err: target parent somehow exists in '$parent_dir'"
    else
        rm -f "$parent_dir"
        mkdir -p "$parent_dir"
    fi
}

handle_dir(){
    local bi="$1"
    local i="$2"

    local target_name="${bi%.*}"

    # magic: fish-config -> config/fish; HOME.d -> /home/baba
    local target_folder="$(perl -e '($a)=@ARGV; print(join("/", reverse( map { (/^[A-Z]+$/)?$ENV{$_}:$_ } split("-", $a))))' "$target_name")" 

    local target_path=
    case "$target_folder" in
        /*) target_path="$target_folder" ;;
        *) target_path="$HOME/.$target_folder" ;;
    esac

    install_to_linkdir "$i" "$bi"


    case "$bi" in
        -*|*-) die "Err: invalid dirname '$bi'" ;;
       *.dd|*.dotdir) 
            create_parent_dir "$target_path"
            libutil__link_to_target "$i" "$target_path" 
           ;;
        *.df|*.dotfiles) 
            target_join_path=
            case "$target_path" in
                $HOME) target_join_path="$HOME/." ;;
                $HOME/) target_join_path="$HOME." ;;
                *) 
                    mkdir -p "$target_path" || die "Err: could not create '$target_path'"
                    target_join_path="$target_path/"
                    ;;
            esac

            for ii in "$i"/* ; do
                [ -f "$ii" ] || continue
                local bii="${ii##*/}"

                case "$bii" in
                    *-*-*) die "Err: invalid name $bii, not more than one hipher" ;;
                    *-*)
                        local subdir="${bii%-*}"
                        local fname="${bii##*-}"
                        mkdir -p "$target_path/$subdir"
                        echo libutil__link_to_target "$ii" "${target_join_path}/$subdir/$fname"
                        libutil__link_to_target "$ii" "${target_join_path}/$subdir/$fname"
                        install_to_linkdir "$ii" "$fname"
                        ;;
                    *)
                        #  echo libutil__link_to_target "$ii" "${target_path}${bii}"
                        libutil__link_to_target "$ii" "${target_join_path}${bii}"
                        install_to_linkdir "$ii" "$bii"
                        ;;
                esac
                
            done
            ;;
        *) 
            echo "Info: skipping '$bi'" >&2 
            continue
            ;;
    esac
}

handle_dotfiles(){
    local cwdir="${1:-}"
    [ -n "$cwdir" ] || die "Err: no cwdir"

    [ -d "$cwdir" ] || die "Err: no valid cwdir '$cwdir'"

    local cwdir_abs=
    cwdir_abs="$(libutil__abspath "$cwdir")" || die "Err: could not get abs path"
   

    for i in "$cwdir_abs"/* ; do
        [ -e "$i" ] || continue

        local bi="${i##*/}"

        if [ -f "$i" ]; then
            case "$bi" in
                *profile|*rc)
                    libutil__link_to_target "$i" "$HOME/.$bi" 
                    ;;
                *) : ;;
            esac
        elif [ -d "$i" ]; then
            handle_dir "$bi" "$i"
        else
            info "skip invalid item '$i'"
        fi
               


    done
}

handle_dotfiles "$PWD"
