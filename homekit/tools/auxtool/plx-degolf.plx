# ! perl -w -n 
#
# decompresses a perl plx oneliner to a script 
#

#
#
BEGIN{
    $i=0;
    $nl=undef;
}
chomp;
#my(@line) = split(/("[^"]*")/);
#my(@line)=  split(/("[^"]*"|q\[[^\]]*\]|s\/.*\/g)/);
my(@line)=  split(/("[^"]*"|q\[[^\]]*\]|s\/[^\/]*\/g|\/[^\/]*\/g)/);
# 38         unless(/^"|^s\/|^\q\[/){

$pp=sub{
    my ($str) =@_;
    print(($nl) ? "\n" .  " " x (4 * $i) . $str : $str);
    undef $nl;
};


foreach my $piece (@line){
    chomp;
    # if(/^"/){
    if($piece =~ /^"|^s\/|^q\[|^\//){
        $pp->($piece);
        undef $nl;
    }else{
        foreach my $ch (split("", $piece)){
            if($ch =~ /\{/){
                $pp->($ch);
                ++$i;
                $nl=1;
            }elsif($ch =~ /\;/){
                $pp->($ch);
                $nl=1;
            }elsif($ch =~ /\}/){
                $i--;
                $pp->($ch);
            }else{
                $pp->($ch);
            }
        }
    }
}

