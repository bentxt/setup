aliases_cache_reset(){
    unset IS_FISH_SHELL_INITIALIZED
    /bin/sh ~/kit/utils/aliases-cache-generate.sh
}

alias aliases-cache-reset='aliases_cache_reset'
alias reset-aliases-cache='aliases_cache_reset'
