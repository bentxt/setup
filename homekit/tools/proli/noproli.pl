use strict;

use warnings;
use File::Basename;

# NAME
# noproli - a literal programming tool
#
# SYNOPSIS
#
# noproli [OPTION]... COMMAND <input file> [output-item]
#
# DESCRIPTION
#
# # ## 1. Weave Mode: Producing Documentation
#
# * Write a mixture of a leading article in text format and a bunch of code files.
# * Advised for post with longer code files.
# * The text file can contain references and extracts of real code files
# * The weave command stitches all together in one text file
#
# ## 2. Tangle Mode: Producing Code
#
# - Entire blog post is written in a text file including the code
# - Advised for shorter snippets of code
# - The text contains named code blocks that can be extracted
#
# COMMANDS
#   tangle:     extract code from text
#   weave:      create documentation from text and code
#   src2html:   translate source code into html with line numbers
#
# Input File
#
# Depending on the COMMAND either a file containing documentation or code
#
# Output item:
#
#   - for the `weave` and `src2html` command the item is the output file
#   - for the `tangle` command the item is the output directory
#
#
# OPTIONS
#
# General Options:
#
# [-h|--help]:      Show this help
# [-v|--verbose]:   Show more message on completed actions
# [-w|--over[w]rite]: Overwrite existing files. Handle with care!
# [-t|--[t]angle-target]:   where to put the tangled files
#
# [-d|--definition VAR=val]: set variables for preprocessor variables
#   at the cli: -d '$name=James Joyce' 
#   somewhere in the text: ... Author: {{$name}} 
#
# Options for Weave:
# [-c]|--htmlcode
#
#
# usage: ' [-d|--definition var=val] [-h|--help] [-v|--verbose] [-w|--over[w]rite] [-[c]|--htmlcode] <weave|tangle|src2html> <input file> [output item]';
#
# src2html: 


my $rx_block_start= qr/^\s*\`\`\`+\s*\{\s*#/;
my $rx_block_start_tangle= qr/$rx_block_start([\w\.]+)\s+\.[\w\s\.]+\s*\}\s*$/;
my $rx_block_end = qr/^\s*\`\`\`+\s*$/;


my $htmlcode_dir = '.';
my $opt_overwrite;
my $opt_verbose;
my @definition_list;


sub help {
    my ($usage) = @_;
    open (my $fh, '<', $0) || die "Err: can not open $0";
    my $incmt;
    print "Help:\n\n" unless $usage;
    while(<$fh>){
        chomp;
        if($incmt){
            last if  ( /^\s*([^#\s])/);
        }else{
            $incmt = 1 if (/^\s*#+[^!]*/)
        }
        if($incmt){
            if ($usage){
                if (/^\s*\#+\s*(usage:.*)$/){
                    print "$1\n" ;
                    last;
                }
            }else{
                print "$1\n" if (/^[\s\#]*(.*)/) ;
            }
        }
    }
    exit 1;
}

my $COMMAND;
while (my $arg = shift @ARGV ){
    if($arg =~ /^-h|--help/){
        help;
    }elsif($arg =~ /^-d|--definition/){
        my $definition = shift @ARGV;
        die "Err: no definition " unless $definition;
        push @definition_list, $definition;
    }elsif($arg =~ /^-w|--overwrite/){
        $opt_overwrite=1;
    }elsif($arg =~ /^-c|--htmlcode/){
        $htmlcode_dir= shift @ARGV;
        die "Err: no argument for htmlcode_dir" unless $htmlcode_dir;
    }elsif($arg =~ /^-v|--verbose/){
        $opt_verbose=1;
    }elsif($arg =~ /^-+.+/){
        die "Err: wrong argument: $arg";
    }else{
        $COMMAND = $arg;
        last;
    }
}

my ($INPUT, $OUTPUT) = @ARGV;

help(1) unless $COMMAND;
help(1)  unless $INPUT;




my %definitions ;
foreach(@definition_list){
    if(/\$([a-z]+)\=(\w+)/){
        $definitions{$1} = $2;
    }elsif(/\$([a-z]+)/){
        $definitions{$1} = 1;
    }else{
        die "Err: invalid definition $_"
    }
}

sub tangle_write_code {
    my ($blockref, $codefile) = @_;
    if( -f $codefile){
        die "Err: codefile $codefile already exists, see --help" unless $opt_overwrite;
    }

    if($codefile =~ /\//){
        my($codefile_basename, $codefile_dir) = fileparse($codefile);
        mkdir $codefile_dir unless -d $codefile_dir;
    }
    open (my $fh, '>', $codefile) || die "Err: could not handle codefile '$codefile'";
    print $fh @$blockref;
    print "code file written to $codefile\n" if $opt_verbose;
}

sub tangle {
    die "Err: INPUT $INPUT is not a file" unless -f $INPUT;
    open (my $ifh, '<', $INPUT) || die "Err: could not open INPUT";

    my $output_dir='';
    if ($OUTPUT){
        $output_dir = "$OUTPUT/";
        mkdir $output_dir unless (-d $output_dir);
    }

    my $inblock;
    my $codefile;
    my @block;
    while(<$ifh>){
        if ($inblock){
            if (/$rx_block_end/){
                undef $inblock
            }elsif (/$rx_block_start/){
                die "Err: cannot have a block tangle start in another block start";
            }else{
                push @block, $_;
            }
        }else{
            if (%definitions){
                foreach my $key (keys %definitions){
                    my $val = $definitions{$key};
                    s/\{\{\s*\$$key\s*\}\}/$val/g if( /\{\{\s*\$$key\s*\}\}/);
                }
            }
            if (/$rx_block_start/){
                if (/$rx_block_start_tangle/){
                    my $codefile_new = $1; 
                    if($codefile){
                        if ($codefile ne $codefile_new){
                            tangle_write_code(\@block, "${output_dir}${codefile}");
                            undef @block;
                        }
                    }
                    $codefile = $codefile_new;
                    $inblock = 1;
                }else{
                    die "Err: invalid line $_, something wrong with that tangle line"
                }
            }
        }
    }
    die "Err: code block is not closed" if $inblock;
    tangle_write_code(\@block, "${output_dir}${codefile}") if @block;
}


my %syntaxes = qw(ahk ahk ahkl ahk htaccess apacheconf apache.conf apacheconf apache2.conf apacheconf sh bash ksh bash bash bash ebuild bash eclass bash bat bat cmd bat bmx blitzmax bf brainfuck b brainfuck c c h c cfm cfm cfml cfm cfc cfm tmpl cheetah spt cheetah cl cl lisp cl el cl clj clojure cljs clojure cmake cmake CMakeLists.txt cmake coffee coffeescript sh-session console cpp cpp hpp cpp c++ cpp h++ cpp cc cpp hh cpp cxx cpp hxx cpp pde cpp cs csharp pyx cython pxd cython pxi cython d d di d pas delphi diff diff patch diff dpatch dpatch darcspatch dpatch duel duel jbst duel dylan dylan dyl dylan erl-sh erl erl erlang hrl erlang flx felix flxh felix f fortran f90 fortran s gas S gas kid genshi vert glsl frag glsl geo glsl plot gnuplot plt gnuplot go go 1 groff 2 groff 3 groff 4 groff 5 groff 6 groff 7 groff man groff haml haml hs haskell html html htm html xhtml html xslt html hy hybris hyb hybris ini ini cfg ini ik ioke weechatlog irc ll llvm lgt logtalk lua lua wlua lua mak make Makefile make makefile make Makefile.* make GNUmakefile make mao mako mhtml mason mc mason mi mason autohandler mason dhandler mason md markdown mo modelica def modula2 mod modula2 moo moocode mu mupad myt myghty autodelegate myghty asm nasm ASM nasm ns2 newspeak m objectivec j objectivej ml ocaml mli ocaml mll ocaml mly ocaml pl perl pm perl php php php3 php php4 php php5 php ps postscript eps postscript pot pot po pot pov pov inc pov prolog prolog pro prolog pl prolog properties properties proto protobuf py python pyw python sc python SConstruct python SConscript python tac python rb rb rbw rb Rakefile rb rake rb gemspec rb rbx rb duby rb Rout rconsole r rebol r3 rebol cw redcode rst rst rest rst scm scheme scss scss st smalltalk tpl smarty sources.list sourceslist S splus R splus sqlite3-console sqlite3 squid.conf squidconf ssp ssp tcl tcl tcsh tcsh csh tcsh tex tex aux tex toc tex txt text v v sv v vala vala vapi vala vb vbnet bas vbnet vm velocity fhtml velocity vim vim .vimrc vim xml xml xsl xml rss xml xslt xml xsd xml wsdl xml xqy xquery xquery xquery xsl xslt xslt xslt yaml yaml yml yaml );


sub get_output_handler{
    if ($OUTPUT){
        open (my $ofh, '>', $OUTPUT) || die "Err: could not open $OUTPUT";
        if ( -f $OUTPUT){
            die "Err: OUTPUT $OUTPUT already exists" unless $opt_overwrite;
        }
        return $ofh;
    }else{
        return \*STDOUT;
    }
}

sub weave {
    my $ofh = get_output_handler;
    my $lnr = 0;

    die "Err: INPUT $INPUT is not a file" unless -f $INPUT;
    open (my $ifh, '<', $INPUT) || die "Err: could not open INPUT";

    while(<$ifh>){
        $lnr++;
        if (%definitions){
            foreach my $key (keys %definitions){
                my $val = $definitions{$key};
                s/\{\{\s*\$$key\s*\}\}/$val/g if( /\{\{\s*\$$key\s*\}\}/);
            }
        }
        if(/^#include[^\w]*/){
            my ($sourcepath, $from, $to) = ($_ =~ /^#include\s+\"\s*([\w\.]+)\s*\"\s*(\d*)\s*(\d*)\s*$/);

            if($sourcepath){
                die "Err: sourcepath '$sourcepath' is missing" unless -f $sourcepath;
            }else{
                die "Err: inlude statement is missing the filename" unless $sourcepath;
            }
            my($source_basename) = fileparse($sourcepath);
            my($source_name, $dirname, $suffix) = fileparse($sourcepath, qr/\.[^.]*/);
            my $htmlcode_path;
            my $htmlfile_path = "$htmlcode_dir/$source_basename.html";
            my $stx;
            if($suffix){
                my $ext = substr $suffix, 1;
                $stx = (exists $syntaxes{$ext}) ? ' .' . $syntaxes{$ext} . ' '  : '';
            }
            
            open(my $fh, '<', $sourcepath) || die "Err: can not open '$sourcepath'";
            my $i = 0;
            if ( $from){
                print $ofh "\n[$source_basename]($htmlfile_path#$from):\n\n" ;
                print $ofh '```{' . $stx . qq(startFrom="$from") . ' .numberLines ' .  "}\n";
                if($to){
                    while(<$fh>){
                        if (($i >= $from ) and ($i <= $to )){
                            print $ofh $_ ;
                        }
                        $i++;
                    }
                    die "Err: range could not reach until $to in $sourcepath on line $lnr" if ($i<$to);
                }else{
                    while(<$fh>){
                        $i++;
                        print $ofh $_ if ($i == $from);
                    }
                }
                print $ofh "```\n";
            }else{
                print $ofh "\n[$source_basename]($htmlfile_path) :\n\n";
                print $ofh '```{' . $stx . ' .numberLines ' .  "}\n";
                while(<$fh>){ print $_ } print $ofh "```\n";

            }


        }else{
            print $ofh $_
        }
    }
}


if ($COMMAND eq 'tangle'){
    tangle
}elsif ($COMMAND eq 'weave'){
    weave
}elsif ($COMMAND eq 'test'){
    die %definitions; 
}



__END__

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
<meta charset="utf-8">
<meta name="generator" content="pandoc">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
<title></title>
<style>
html {
color: #1a1a1a;
background-color: #fdfdfd;
}
h1, h2, h3, h4, h5, h6 {
margin-top: 1.4em;
}

table .lnr {
width:auto;
text-align:right;
white-space: nowrap
}
table .src {
width: 100%
}
table {
white-space: nowrap;
border-collapse:collapse;
border-spacing:0;
width:100%;
border: 1px solid;
font-family: "Courier New", monospace;
white-space: pre;
}

tr { border: none; }

table tr td {
border-right: 1px solid black;
color: black
}

</style>
</head>
<body>
<h1></h1>

<table>
<tbody>


