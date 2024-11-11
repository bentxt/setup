#!/bin/perl
#
#  perl -w -n -e 


# # NAME
#
# proldoc - extract help text
#
# # SYNOPSIS
# 
##   proldoc [OPTIONS] [FILE]
# 
# # DESCRIPTION
# 
# Embed markdown help text on the top of the extract and extract it with propod
#
# While the syntax is markdown, it is based on the POD documentation system.
#
# Advantages:
# - main advantage is the proliferation of the various pod* tools on *nix
# - pod2man creates good man files
# - pod2html create clean html files
# - is based on the pod docu
#
# Extract it with:
#
#
#
# # FILE
#
# You can use every file or script as input
#
# # OPTIONS
#
# -h|--help
#   : call helpthis commmand rocks
#

chomp;
if($i){
    if(/^s*[^#]/){
        exit;
    };
}else{
    if(/^\#+([^\!])/){
            $i=1;
    };
};
unless($i){
    next;
};
s/^#+\s?//g;
print("$_\n"); 

