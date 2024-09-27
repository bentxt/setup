# Thougths about where/how to manage/store fish configs
# - fish autoload of configs and scripts via ~/.config/fish/conf.d
# - autoload has negative impact when in non-interactive mode (scripting)
# - control the inclusion manually here in ~/.config/fish/config.fish

# start in insert mode


set -gx GPG_TTY (/usr/bin/tty)

### Interactive Shell Only
# if this called during the init of a script its time to go
# was not a good idea when using fish from ssh


# sourcing for environment variables and aliases


set DEBUG ''

if test -z "$UNIVERSAL_FISH_PROFILE_INITIALIZED"
    if test -f $HOME/.config/fish/universals.fish 
        source $HOME/.config/fish/universals.fish && set -xU UNIVERSAL_FISH_PROFILE_INITIALIZED 1
    else
        echo "cannot find  $HOME/.config/fish/universals.fish, skip"
    end
end

function sourcing_files        

    for dir in $argv
        [ -n "$DEBUG" ] && echo "try dir '$dir'"
        [ -d "$dir" ] || continue

        for f in $dir/*.*sh
            [ -n "$DEBUG" ] && echo "try file '$f'"
            [ -f "$f" ] || continue
            switch $f
                case '_*' 'lib*'
                    continue
                case '*.sh' '*.fish'
                    [ -n "$DEBUG" ] && echo source $f
                    source $f
            end
        end
    end
end



######## NONINTERACTIVE SHELL


if test -f "$HOME/.profile"
    . $HOME/.profile
else
    echo "Warn: ~/.profile not found" >&2
end

sourcing_files "$HOME/kit/conf"


status is-interactive || return 0 


######## INTERACTIVE SHELL


fish_vi_key_bindings insert


sourcing_files "$HOME/kit/conf"

sourcing_files "$HOME/kit/aliases"

if [ -n "$XDG_CACHE_HOME" ] 
    sourcing_files "$XDG_CACHE_HOME/utils_aliasutils"
else
    sourcing_files "$HOME/.cache/utils_aliasutils"
end


function goto

    if [ -z "$argv" ] 
        echo fail need an argument
        return 1
    end


    set -l realdir (sh ~/kit/functions/print-real-dir.sh "$argv")

    if [ -n "$realdir" ] 
        cd "$realdir"
        echo "Ok: jumped to '$realdir'"
    else
        echo "Fail: could not get realdir '$realdir'"
    end
end


if command -v starship
    starship init fish | source
end


# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH


test -f $BKB_TOOLSET/aliases/functions.fish && source $BKB_TOOLSET/aliases/functions.fish
