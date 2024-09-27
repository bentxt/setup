#!/bin/perl
#
#  perl -w -n -e 


# # NAME
#
# code2usage - extract usage text
#
# # SYNOPSIS
# 
##   perl -w -n -e code2usage.plx   [FILE]
# 
# # DESCRIPTION
# 
# Embed markdown help text on the top of the extract and extract it with propod
#

#

chomp;
if($i){
    if($syno){
        if(/^s*#+\s*(\w+.*)/){
            print "Usage: $1\n";
            exit;
        };
    }else{
        if(/^s*[^#]/){
            exit;
        }elsif(/^s*#+[\s\#]*SYNOPSIS/){
            $syno=1;
        };
    };
}else{
    if(/^\#+([^\!])/){
            $i=1;
    };
};
unless($i){
    next;
};
