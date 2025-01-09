#
# Avoiding LD_LIBRARY_PATH: The Options
# https://blogs.oracle.com/solaris/post/avoiding-ld_library_path-the-options
# .... The best way to use LD_LIBRARY_PATH is interactively, as a short term aid for testing or development.  ....
#
#
# PROFILE_HOME_DIRS
# PROFILE_HOME_LANGS
# PROFILE_SYS_DIRS
# PROFILE_SYS_LANGS
# PROFILE_PATH_DIRS

export LD_LIBRARY_PATH_DIRS="$(runperl 'search-dirs' "$PROFILE_SYS_DIRS" 'lib' 'lib64')"

command -v brew > /dev/null && export BREW_OPENSSL_PREFIX="$(brew --prefix openssl 2>/dev/null)"
test -n "$BREW_OPENSSL_PREFIX" && test -d "$BREW_OPENSSL_PREFIX/lib" && export LD_LIBRARY_PATH_DIRS="$BREW_OPENSSL_PREFIX/lib:$LD_LIBRARY_PATH_DIRS"

export PKG_CONFIG_PATH="$(runperl 'search-dirs' "$PROFILE_SYS_DIRS" 'pkgconfig')"

export MANPATH_DIRS="$(runperl 'search-dirs' "$PROFILE_SYS_DIRS" 'man')"
export MANPATH="$MANPATH_DIRS"


# PATH
#
export PATH_HOME_DIRS="$(runperl 'search-dirs' -prefix "$HOME" "$PROFILE_HOME_DIRS" 'bin' 'sbin')"
export PATH_HOME_LANG_DIRS="$(runperl 'search-dirs' -prefix "$HOME" -names "$PROFILE_HOME_LANGS" "$PROFILE_HOME_DIRS" 'bin' )"
export PATH_HOME_DIRS2="$(runperl 'merge-colonlists' "$PATH_HOME_DIRS" "$PATH_HOME_LANG_DIRS")"


export HOST_LANGS="$(runperl 'read-hostvars' "$HOSTVARS_FILE" '.bin' )"
export PATH_SYS_LANG_DIRS="$(runperl 'search-dirs' -names "$HOST_LANGS" "$PROFILE_SYS_DIRS" 'bin')"


export PATH_SYS_DIRS="$(runperl 'search-dirs' "$PROFILE_PATH_DIRS")"


export PATH="$PATH_HOME_DIRS2:$PATH_SYS_LANG_DIRS:$PATH_SYS_DIRS:$PATH"

export PROFILE_SETUP_LOADED=1



