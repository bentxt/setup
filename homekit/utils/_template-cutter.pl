use strict;
use warnings;

# 3 sections
# header
# prelude
# module__functions
# modulino

my ($filename, @words) = @ARGV;

die 'usage: <filename> args ...' unless $filename;


my $regex_alpha = '[a-zA-Z0-Z_]+'; 
my $regex_post = '\s*\(\s*\)\s*\{\s*';

my $func_regex = qr/^\s*${regex_alpha}__${regex_alpha}${regex_post}/;
my $main_regex = qr/^\s*(${regex_alpha}__main)${regex_post}/;

open (my $fh, '<', $filename) || die "Err: could not open $filename";

my (@regexes,  $switch, $print_header, $print_modulino, $print_module_funcs );
my $word;
for  (@words){
    $word = $_;
    if($word eq 'header'){
        $print_header = 1; 
    }elsif($word eq 'prelude'){
        $switch = 1; 
    }elsif($word eq 'modulino'){
        $print_modulino = 1;
    }else{
        $print_module_funcs = 1;
        push @regexes, qr/^\s*(${regex_alpha}__${word})${regex_post}/; 
    }
}


my $regex = shift @regexes if @regexes;

my @caller_lines;

sub match_func {
    my ($capture) = @_;
    push @caller_lines, $capture ;
    if(@regexes){
        $regex = shift @regexes ;
    }else{
        undef $regex;
    }
    $switch = 1;
}

my $modulino_regex = qr/^\s*##+\s+Modulino\s*/  ;

my $header = 1 ;
my $main_line;
sub looper {
    foreach(<$fh>){
        chomp;

        undef $header if($_ =~ /^\s*[^#\s]+/);

        if ($header){
            print $_ . "\n" if $print_header;
            next
        }


        if(/$func_regex/){
            undef $switch;
            if ($print_module_funcs){
                if( (defined $regex) && ($_ =~  /$regex/)){
                    if($_ =~  /$main_regex/){
                        $main_line = $1 ;
                        $switch = 1;
                    }else{
                        match_func $1;
                    }
                }

            }
        }elsif((defined $modulino_regex ) && ($_ =~ /$modulino_regex/)){
            $switch = ($print_modulino)  ? 1 : undef;
        }

                print $_ . "\n" if $switch;
    }

    unless($print_modulino){
        my $last_line = pop @caller_lines;
        if($main_line){
            print "if [ -t 0 ]; then\n";
            print "    " . $main_line . ' 0 "$@" ' . "\n"; 
            print "else\n";
            print "    die 'Err: run program interactively'\n";
            print "fi\n";
        }
        foreach(@caller_lines){
            print $_ . ' || die ' . "'Abort $_ ...'\n";
        }
        print $last_line . ' "$@" || die ' . "'Abort $last_line ...'\n" if $last_line;
    }
}

if (@words){
    looper
}else{
    foreach(<$fh>){
        print $_ 
    }
}


