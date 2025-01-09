# ------------
#
# programmatically set profiles variables
#
#

warn(){ echo "$*" >&2; }
die(){
    warn "$*"
    exit 1;
}

[ -n "$CONFIG_PROFILE_DIR" ] || die  "Err: no config shell dir"

PRELUDE_SCRIPT="$CONFIG_PROFILE_DIR/profile-prelude.sh"
if [  -f "$PRELUDE_SCRIPT" ]; then
    source "$PRELUDE_SCRIPT" || die "Err: could not source '$PRELUDE_SCRIPT'"
else
    warn "Warn: could not load '$PRELUDE_SCRIPT'"
fi

UTILS_SCRIPT="$CONFIG_PROFILE_DIR/setup-utils.pl"
if [ ! -f "$UTILS_SCRIPT" ]; then
    echo "Warn: could not load '$UTILS_SCRIPT'"
    return 
fi


runperl(){ perl "$UTILS_SCRIPT" "$@" ; }

SETUP_SCRIPT="$CONFIG_PROFILE_DIR/profile-setup.sh" 


if [ -f "$SETUP_SCRIPT" ]; then
    source "$SETUP_SCRIPT"  || die "Err: could not load setup $SETUP_SCRIPT"
else
    die "Err: could not load $SETUP_SCRIPT" 
fi

