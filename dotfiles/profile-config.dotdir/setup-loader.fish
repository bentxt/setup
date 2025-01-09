# ------------
#
# programmatically set profiles variables
#
#

function warn
    echo "$argv" >&2
end

function die
    warn "$argv"
    exit 1
end

test -n "$CONFIG_PROFILE_DIR"  || die  "Err: no config shell dir"


set PRELUDE_SCRIPT "$CONFIG_PROFILE_DIR/profile-prelude.sh"
if [  -f "$PRELUDE_SCRIPT" ]
    source "$PRELUDE_SCRIPT" || die "Err: could not source '$PRELUDE_SCRIPT'"
else
    warn "Warn: could not load '$PRELUDE_SCRIPT'"
end
set UTILS_SCRIPT "$CONFIG_PROFILE_DIR/setup-utils.pl"
if [ ! -f "$UTILS_SCRIPT" ]
    echo "Warn: could not load '$UTILS_SCRIPT'"
    return 
end


function runperl
    perl "$UTILS_SCRIPT" $argv
end

set SETUP_SCRIPT "$CONFIG_PROFILE_DIR/profile-setup.sh" 


if [ -f "$SETUP_SCRIPT" ]
    source "$SETUP_SCRIPT"  || die "Err: could not load setup $SETUP_SCRIPT"
else
    die "Err: could not load $SETUP_SCRIPT" 
end


# cannot set MANPATH only with export
#https://github.com/fish-shell/fish-shell/issues/2090
test -n "$MANPATH_DIRS" &&  set -gx MANPATH "$MANPATH:$MANPATH_DIRS"
