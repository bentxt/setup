chomp;
if($i){
    if(/^s*[^#]+$/){
        last;
    };
}else{
    if(/^\#+([^\!])/){
        $i=1;
    };
}unless($i){
    next;
};
s/^#+\s?//g;
s/\*\*([^\*]+)\*\*/B<$1>/g;
s/(http[s]*\:\/\/[^\s]+)/L<$1>/g;
s/^\s*(\-+\w+.*)/=item\sB<$1>/g;
s/^\s*([\-\*]\s+.*)/=item\s$1\n/g;
if(s/^\s*(\#+)//g){
    if($enum){
        print("\n=back\n\n");
    };
    undef($enum);
    @l=split("",$1);
    print("=head".scalar(@l));
}elsif(/^=item/){
    unless($enum){
        print("\n=over 4\n\n");
    };
    $enum=1;
};
print("$_\n");
END{
    if($enum){
        print("\n=back\n\n");
    };
};