

function aliases-cache-reset
    set -e IS_FISH_SHELL_INITIALIZED
    /bin/sh ~/kit/utils/aliases-cache-generate.sh
end

alias reset-aliases-cache='aliases-cache-reset'
