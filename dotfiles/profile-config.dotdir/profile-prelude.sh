# XDG
#
test -d "$XDG_CACHE_HOME" || mkdir -p "$XDG_CACHE_HOME"
test -d "$XDG_RUNTIME_DIR" || mkdir -p "$XDG_RUNTIME_DIR"
test -d "$XDG_STATE_HOME" || mkdir -p "$XDG_STATE_HOME"
test -d "$XDG_DATA_HOME" || mkdir -p "$XDG_DATA_HOME"
test -d "$XDG_CONFIG_HOME" || mkdir -p "$XDG_CONFIG_HOME"


## EXES
# Cross interactive shell

test -n "$MD5SUM_EXE" || export MD5SUM_EXE="$(command -v md5sum)"
test -n "$GFIND_EXE" || export GFIND_EXE="$(command -v gfind)"
test -n "$REALPATH_EXE" || export REALPATH_EXE="$(command -v realpath)"
#  - readlink -f
#  - perl (perl -MCwd -e 'print Cwd::abs_path shift' ga.txt)

test -n "$HOST_OS" || export HOST_OS="$(uname | tr '[:upper:]' '[:lower:]')"

test -n "$HOST_NAME" || export HOST_NAME="$(hostname | perl -pe 's/\..*$//;s{^.*/}{}')"

test -n "$HOST_NAME" && export  HOSTVARS_FILE="$HOSTVARS_DIR/$HOST_NAME.conf"


