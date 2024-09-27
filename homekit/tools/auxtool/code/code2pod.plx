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
    if( /^s*[^#]/){
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
s/\*\*([^\*]+)\*\*/B<$1>/g;
s/(http[s]*\:\/\/[^\s]+)/L<$1>/g;
s/^\s*(\-+\w+.*)/=item B<$1>/g; 
s/^\s*([\-\*]\s+.*)/=item $1\n/g;
if(s/^\s*(\#+)//g){ 
    if($enum){
        print("\n=back\n\n");
    };
    undef($enum);  
    @l=split("",$1);
    print("=head" . scalar(@l)) ;
}elsif(/^=item/){ 
    unless($enum){
        print("\n=over 4\n\n");
    };
    $enum=1 ;
};
print("$_\n"); 

END{
    if($enum){
        print("\n=back\n\n");
    };
};
