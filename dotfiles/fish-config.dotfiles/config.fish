# Thougths about where/how to manage/store fish configs
# - fish autoload of configs and scripts via ~/.config/fish/conf.d
# - autoload has negative impact when in non-interactive mode (scripting)
# - control the inclusion manually here in ~/.config/fish/config.fish

# start in insert mode




### Interactive Shell Only
# if this called during the init of a script its time to go
# was not a good idea when using fish from ssh


# sourcing for environment variables and aliases

set DEBUG ''

if not status --is-interactive
	exit
end

test -f $HOME/.profile && source $HOME/.profile
test -f  $HOME/.config/profile/setup-loader.fish  && source  $HOME/.config/profile/setup-loader.fish 

exit


exit




set -gx GPG_TTY (/usr/bin/tty)

fish_vi_key_bindings insert

exit


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

