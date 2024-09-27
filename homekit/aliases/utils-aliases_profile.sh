# source by ~/.profile
#
#

test -n "$AUXFILES" || echo "Warn: AUXFILES is not defined" >&2 

alias list-utils="ls $AUXFILES/utils/ | perl -ne '/^_/ || /^lib/  || print'"

alias untar="sh $AUXFILES/utils/unpack.sh"

alias templator="dash $AUXFILES/utils/templator.dash"

alias cwdcopy="dash $AUXFILES/utils/cwd.dash copy"
alias pwdcopy=cwdcopy
alias ,pwdcopy=cwdcopy
alias ,cwdcopy=cwdcopy

alias pwdc='cwdcopy'


alias help2man=',help2man'


alias docsend=',watchtask send doc'


alias ,send-out=',watchtask -n out  send '
alias 'so'=,send-out
alias 'os'=,send-out
alias send-out=,send-out
alias ,out-send=,send-out
alias out-send=,send-out


alias ,send-doc=',watchtask -n doc send '
alias 'do'=,send-doc
alias 'od'=,send-doc
alias send-doc=,send-doc
alias ,doc-send=,send-doc
alias doc-send=,send-doc

alias auxtmux="dash $AUXFILES/utils/dirtmux.dash set AUX"
alias poptmux="dash $AUXFILES/utils/dirtmux.dash set POP"
alias buildtmux="dash $AUXFILES/utils/dirtmux.dash set BUILD"

alias del="dash $AUXFILES/utils/delete.dash "

#function alltmux
#    dash $HOME/kit/utils/dirtmux.dash set AUX
#    dash $HOME/kit/utils/dirtmux.dash set BUILD
#    dash $HOME/kit/utils/dirtmux.dash set MAIN
#end


#alias ,generate-kit-aliases="dash $AUXFILES/utils/aliasutils.sh base-gen '$HOME/kit' 'utils' 'nih-utils' 'vi-utils' 'commands' 'vendor'"
#alias generate-kit-aliases=,generate-kit-aliases
#alias kit-aliases=,generate-kit-aliases

alias mysqids="bash $AUXFILES/vendor/mysqids.bash"

alias codeblog="dash $AUXFILES/tools/codeblog/codeblog.sh"


