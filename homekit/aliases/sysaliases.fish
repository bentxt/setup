

alias remove-alias='functions --erase'

function ,m
    mkdir -p $argv
    cd $argv
end

alias m=,m

alias fish-shell-reset='fish_shell_reset'

alias ,reset-fish-profile='set -e UNIVERSAL_FISH_PROFILE_INITIALIZED'
alias reset-fish-profile=,reset-fish-profile
