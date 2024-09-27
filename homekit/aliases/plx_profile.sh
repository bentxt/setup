export PLXSH="$AUXFILES/plx/plx.sh"

alias plx="sh $PLXSH"


# todo: contains a lot of single quotes, could not make it fish compatible
#  enough
alias quotify="sh $PLXSH replace/quotify.plx"
