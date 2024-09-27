# FUUUUUU

my $cmd;
while (my $arg = shift @ARGV) {
    if ($arg =~ /^-u$|^--user$/ ){
        print 'uuuser'
    }elsif ($arg =~ /^-h$|^--help$/ ){
        open ($fh, '<', $0) || die 'cannot open ';
        while(<$fh>){
            print "$1\n" if /^\s*#\s(.*)/; 
            exit if /^\s*[^#\s]+/;
        }
        close $fh
    }elsif ($arg =~ /^-/ ){
        print 'break'
    }else{
        $cmd = $arg;
        break
    }
}

print $cmd;
