use strict;

use warnings;
no warnings 'once';

use Data::Dumper 'Dumper';


sub echo {
    print @_;
    print "\n";
}

sub cry {
    print STDERR @_;
    print "\n";
}


sub merge_colonlists{
    # merge two list 'baba:gaga:...' and 'gugu:gaga:...'
    #
    my $opts = shift;

    my %h;
    foreach(@_){
        %h=(%h, map {$_ => 1} split(":",$_))
    }; 
    return keys(%h);
}
 

sub search_directories {
    my $USAGE = '[-name <name>] [-prefix <prefix>] dirs_colonlist  suffixes';
    my $opts = shift;
    my ( $dirs_colonlist, @suffixes) = @_;
    die "Err: no colonlist given - usage: $USAGE" unless $dirs_colonlist;
    
    my $prefix = (exists $opts->{prefix}) ? $opts->{prefix} : undef;

    my %names;
    if (exists $opts->{names}){
        foreach my $keyval (split(':', $opts->{names})){
            $keyval=~ s/^\s+|\s+$//g;
            my ($key, $val) = split('=', $keyval);
            $key=~ s/^\s+|\s+$//g;
            $val=~ s/^\s+|\s+$//g if $val;
            $names{$key} = $val;
        }
    }


    my @bindirs;

    foreach my $dir (split(':', $dirs_colonlist)){
        my $dirvar = ($prefix) ? "$prefix/$dir" : $dir;

        if(%names){
            foreach my $key( keys %names){
                my $name = $names{$key};
                my $bindir;
                foreach my $suffix (@suffixes){
                    if($name){
                        if(-d "$dirvar/$name/$suffix"){
                            $bindir = "$dirvar/$name/$suffix";
                        }elsif(-d "$dirvar/$name/$name/$suffix"){
                            $bindir = "$dirvar/$name/$name/$suffix";
                        }elsif(-d "$dirvar/$key/$name/$suffix"){
                            # ~/local/dlang/dmd2/osx/bin/
                            $bindir = "$dirvar/$key/$name/$suffix";
                        }
                    }
                    unless($bindir){
                        if(-d "$dirvar/$key/$suffix"){
                            $bindir = "$dirvar/$key/$suffix";
                        }elsif(-d "$dirvar/$key/$key/$suffix"){
                            $bindir = "$dirvar/$key/$key/$suffix";
                        }
                    }
                    last if $bindir;
                }
                push @bindirs, $bindir if $bindir;
            }
        }else{
            foreach my $suffix (@suffixes){
                push @bindirs, "$dirvar/$suffix" if(-d "$dirvar/$suffix");
            }
        }
    }

    return @bindirs
}

sub read_hostvars{
    my $opts = shift;


    my ($hostvar_file, $hostvar_type) = @_;
    
    my $USAGE = '$hostvar_file, $hostvar_type';

    die "Err: no hostvar_file - usage: $USAGE" if not defined $hostvar_file;
    die "Err: no hostvar_type - usage: $USAGE" if not defined $hostvar_type;


    open(my $oh, '<', $hostvar_file) || die "Err: could not open '$hostvar_file'";

    my @l;
    while(<$oh>){
        if(/^([a-zA-Z-]+)$hostvar_type\s*:\s*(.*)\s*$/){
            push @l, "$1=$2"
        }
    }

    close $oh;
    return @l;
}

sub parse_args{
    
    my %opts;
    my @args;
    while(@_){
        my ($arg) = shift @_;

        last unless $arg;

        if($arg =~ /^\-([a-z].*)/){
            my $opt = $1;
            my ($val) = shift @_;
            die "Err: no value for option $opt" unless $val;
            $opts{$opt} = $val;
        }elsif($arg =~ /^\-/){
            die "Err: invalid opt $arg"
        }else{
            push @args, $arg;
        }
    }
    return (\%opts, @args);
}

sub main{
    my $cmd = shift;

    my %subs = (
        echo => \&echo,
        cry => \&cry,
        'merge-colonlists'  => \&merge_colonlists,
        'search-directories'  => \&search_directories,
        'search-dirs'  => \&search_directories,
        'read-hostvars'  => \&read_hostvars,
    );

    die "Err: no cmd given" unless $cmd;

    my $sub = $subs{$cmd}; 

    die "Err: couldn not find a sub for cmd '$cmd'" unless $sub;

    my ($opts, @args) = parse_args(@_);

    print(join(':', $sub->($opts, @args)))
}


#main('read-hostvars', '../hostvars-config.dotdir/moonraker.conf', 'bin', '/Applications:/usr/local/opt');

#main ('merge-colonlists' => 'baba:gugu:gigigi' , 'gigigi:gugu') ;
#
#    my $USAGE = '[-name <name>] [-prefix <prefix>] dirs_colonlist  suffixes';

#main ('search-directories', '/usr/local', 'bin');
#exit;

main(@ARGV) if not caller();


1;
