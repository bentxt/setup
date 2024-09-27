#!/bin/sh
set -u

# # NAME
#
# proligen - Generate Html and other files
#
# # SYNOPSIS
# 
#   proligen [COMMAND] [OPTIONS]... [ARTICLE] [CODEFILES|SOURCEDIR]
# 
# # DESCRIPTION
# 
# The goal for this tool is to produce a html file and provide it with the
# necessary links to code and zip files.
#
# Generally proligen generates the following:
#
# - a html file of the article plus links eventual source code and zip files
#
# If there are source code files proligen produces:
# 
# - a folder containing versioned source file and their html counterparts
# - a zip contining the sources for this article
# 
#
# # COMMANDS
#
# ## doc
#
# The name base is: <name>_<timestamp>
#
# ## blog
#
# The name base is: <daydate>_<name>_<daytime>
#
# ## printhelp
#
# A special command that prints different help formats, then quits
#
#
# # OPTIONS
#
#
# -o|--overwrite
#   : when files are generated, all existing ones are overwritten
#
# -p|--printonly
#   : only printing stuff without executing any further file operations 
#
# -o|--outname
#   : the outname is defined by its PWD name, overwrite with this option
#
# -r|--revision
#   : give a version number to a blog article, eg. for an updated article
#
# -v|--verbose 
#   : show all messages
#
# -a|--archive-path  <archive path>
#
#

warn(){ echo "$*" >&2; }
die(){ warn "$*"; exit 1;  }

revision=
archive_path=
outname=

help_type=
help_arg=

opt_overwrite=
opt_documentation=
opt_verbose=
opt_printonly=

while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help)  help_type='help' ;;
        -a|--archivepath|--archive-path)
            archive_path="${2:-}"
            if [ -z "$archive_path" ] ; then
                help_type='usage'
                help_arg='--[a]rchive-path arg missing'
            fi
            shift
            ;;
        -r|--revision)
            revision="${2:-}"
            if [ -z "$revision" ] ; then
                help_type='usage'
                help_arg='--revision arg missing'
            fi
            shift
            ;;
        -o|--outname)
            outname="${2:-}"
            if [ -z "$outname" ] ; then
                help_type='usage'
                help_arg='--outname arg missing'
            fi
            shift
            ;;
        -w|--overwrite) opt_overwrite=1 ;;
        -p|--printonly) opt_printonly=1 ;;
        -v|--verbose) opt_verbose=1 ;;
        -*) 
            help_type='usage'
            help_arg="invalid arg $1"
            ;;
        *) break ;;
    esac
    shift
done




helpdoc(){
    # find under plxes/helpdoc_[..].plx
    case "${1}" in
        text)
            perl -w -n -e  'chomp;if($i){if(/^s*[^#]/){exit;};}else{if(/^\#+([^\!])/){$i=1;};};unless($i){next;};s/^#+\s?//g;print("$_\n");' "$0"
        ;;
        usage) 
            perl -w -n -e  'chomp;if($i){if($syno){if(/^s*#+\s*(\w+.*)/){print"Usage: $1\n";exit;};}else{if(/^s*[^#]/){exit;}elsif(/^s*#+[\s\#]*SYNOPSIS/){$syno=1;};};}else{if(/^\#+([^\!])/){$i=1;};};unless($i){next;};' "$0"
        ;;
        pod) 
            perl -w -n -e  'chomp;if($i){if(/^s*[^#]/){exit;};}else{if(/^\#+([^\!])/){$i=1;};};unless($i){next;};s/^#+\s?//g;s/\*\*([^\*]+)\*\*/B<$1>/g;s/(http[s]*\:\/\/[^\s]+)/L<$1>/g;s/^\s*(\-+\w+.*)/=item B<$1>/g;s/^\s*([\-\*]\s+.*)/=item $1\n/g;if(s/^\s*(\#+)//g){if($enum){print("\n=back\n\n");};undef($enum);@l=split("",$1);print("=head".scalar(@l));}elsif(/^=item/){unless($enum){print("\n=over 4\n\n");};$enum=1;};print("$_\n");END{if($enum){print("\n=back\n\n");};};' "$0" 
        ;;
    esac
}

help(){
    local type="${1:-}"
    if [ -n "$type" ] ; then
        shift
        case "${type}" in
            usage)
                warn "$*"
                helpdoc 'usage'
                warn 'try running with --help'
            help)
                local prog="$(basename "$0")"
                local progname="${prog%.*}"
                local manfile="$(mktemp -d)/$progname.1" || helptext
                local mantitle="$(perl -e 'print(uc($ARGV[0]))' "$progname")" || helptext
                helppod text | pod2man -c "$mantitle HELP" -n "$mantitle"  > "$manfile" || helptext
                man "$manfile" || helptext
                ;;
            *) die "Err: invalid help type" ;;
        esac
        exit 1
    else
        helpdoc 'text' >&2
        exit 1
    fi
}


if [ -n "$help_type" ] ; then
    help "$help_type" "$help_arg"
    exit 1
fi

command="${1:-}"
shift
[ -n "$command" ] || help 'usage' 'command is missing'

case "$command" in
    printhelp) 
        helpdoc "$@" 
        exit
        ;;
    *) : ;;
esac

readme="${1:-}"
shift
[ -n "$readme" ] || help 'usage' 'readme is missing'


case "${readme##*/}" in
    README|readme|Readme|*.txt|*.md) : ;;
    *) die "Err: there is no valid readme in $readme" ;;
esac

[ -f "$readme" ] || die "Err: readme '$readme' is missing";

src2html(){
    local srcfile="${1:-}"
    [ -n "$srcfile" ] || die "Err: no srcfile given"
    [ -f "$srcfile" ] || die "Err: no valid srcfile given"
    
    # from src2html.plx
    perl -l -n -e 'BEGIN{$lnr=0;foreach(q[<!DOCTYPE html>],q[<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">],q[<head>],q[<meta charset="utf-8">],q[<meta name="generator" content="pandoc">],q[<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">],"<title>$ARGV</title>",q[<style>html {color: #1a1a1a;background-color: #fdfdfd;}],q[h1, h2, h3, h4, h5, h6 {margin-top: 1.4em;}],q[table .lnr {],q[width:auto;text-align:right;white-space: nowrap}],q[table .src {width: 100%}],q[table {white-space: nowrap;border-collapse:collapse;border-spacing:0;width:100%;border: 1px solid;font-family: "Courier New", monospace;white-space: pre;}],q[tr { border: none; }],q[table tr td {border-right: 1px solid black;color: black}],q[</style>],q[</head>],q[<body>],"<h1>$ARGV</h1>",q[<table>],q[<tbody>]){print($_);};};chomp;$lnr++;s/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;s/"/\&quot;/g;s/'\''"'\''"'\''/\&#39;/g;print(q[<tr><td id="].$lnr.q[" class="lnr" >].$lnr.q[</td>]);print(q[  <td class="src" >].$_."</td></tr>\n");END{foreach(qw[</tbody></table></body></html>]){print($_)};}' "$srcfile"
}

stamp_to_date(){
    local stamp="${1:-}"
    [ -n "$stamp" ] || die "Err: no stamp"

    local target="${2:-}"

    local perl_date_time='$ARGV[0]=~/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/ && print "$3.$2.$1, $4:$5:$6"'
    local perl_date='$ARGV[0]=~/^(\d{4})(\d{2})(\d{2})/ && print "$3.$2.$1"'
    local perl_time='$ARGV[0]=~/^(\d{2})(\d{2})(\d{2})/ && print "$1:$2:$3"'

    if [ -n "$target" ] ; then
        case "$target" in
            datetime) perl -e "$perl_date_time" "$stamp" ;;
            date) perl -e "$perl_date" "$stamp" ;;
            time) perl -e "$perl_time" "$stamp" ;;
            *) die "Err: invalid date target" ;;
        esac
    else
        case "$stamp" in
            # year, month, day, hour, minute, second
            [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
                perl -e "$perl_date_time" "$stamp" ;;
            # year, month, day
            [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) perl -e "$perl_date" "$stamp" ;;
            #hour, minute, second
            [0-9][0-9][0-9][0-9][0-9][0-9]) perl -e "$perl_time" "$stamp" ;;
            *) die "Err: invalid stamp" ;;
        esac
    fi
}


## Date Stuff

now_stamp_daydate="$(date +'%Y%m%d')"
now_stamp_time="$(date +'%H%M%S')"
now_stamp_daytime="${now_stamp_daydate}${now_stamp_time}"

now_date_daydate="$(stamp_to_date "$now_stamp_daydate")"
now_date_daytime="$(stamp_to_date "$now_stamp_daytime")"

last_edit_readme="$(date -r "$readme" "+%d.%m.%Y")"

last_edit_stamp=0
get_last_edit(){
    local file="$1"
    [ -n "$file" ] || die "Err: file is empty"
    [ -f "$file" ] || die "Err: file '$file' not exists"

    local  last_edit_stamp_aux="$(date -r "$file" "+%Y%m%d%H%M%S")"
    # alternative (macosx): stat -f "%Sm" -t "%Y%m%d%H%M%S" readme.txt
    if [ -n "$last_edit_stamp_aux" ] ; then
        [ $last_edit_stamp_aux -gt $last_edit_stamp ] && last_edit_stamp=$last_edit_stamp_aux
    fi
}
sourcedir=
if [ -d "${1:-}" ] ; then
    sourcedir="${1:-}"
    [ -d "$sourcedir" ] || die "Err: sourcedir '$sourcedir' not exists"
    for file in "$sourcedir"/* ; do get_last_edit "$file"; done
else
    for file in $@ ; do get_last_edit "$file";  done
fi 

last_edit_date=
last_edit_datetime=
if [ $last_edit_stamp -gt 0 ]; then
    last_edit_date="$(stamp_to_date "$last_edit_stamp" 'date')"
    last_edit_datetime="$(stamp_to_date "$last_edit_stamp" 'datetime')"
fi


# Name building
#
namebase="$(basename "$PWD")"

if [ -n "$outname" ] ; then
    [ -n "$revision" ] && die "Err: no revision if --outnameis given"
else
    [ -n "$revision" ] &&  namebase="${namebase}_v${revision}"
fi


outname=
outname_timed=
case "$command" in
    doc)
        outname="${namebase}"
        outname_timed="${outname}_${now_stamp_daytime}"
        ;;
    blog)
        outname="${now_stamp_daydate}_${namebase}"
        outname_timed="${outname}_${now_stamp_time}"
        ;;
    printhelp) helpdoc "$readme" ;;
    *) die "Err: invalid command: '$command'";;
esac

if [ -n "$opt_documentation" ] ; then
else
fi



codefiles_src_dir="${outname_timed}"
codefiles_html_dir="$codefiles_src_dir"
zipfile="$codefiles_src_dir.zip"

article_html_file="$outname.html"
article_text_file="${outname_timed}.txt"

codefiles_html_dir_archive_path=
article_html_file_archive=
article_html_file_archive_path=
article_text_file_path=
if [ -n "$archive_path" ] ; then 
    article_html_file_archive="${outname_timed}.html"
    article_html_file_archive_path="${archive_path}/${article_html_file_archive}"
    codefiles_html_dir_archive_path="$archive_path/${codefiles_html_dir}"
    article_text_file_path="${archive_path}/${article_text_file}"
else
    article_text_file_path="${article_text_file}"
fi

# echo codefiles_src_dir $codefiles_src_dir
#    20240914_tstl_171332
# echo codefiles_html_dir $code_htmlfiles_dir
#    20240914_tstl_171332
# echo zipfile $zipfile
#    20240914_tstl_171332.zip
# echo article_html_file $article_html_file
#    20240914_tstl.html
# echo article_text_file $article_text_file
#    20240914_tstl_171332.txt
# echo codefiles_html_dir_archive_path= $code_htmlfiles_dir_archive_path
#    ../archives/2024/20240914_tstl_181536
# echo article_html_file_archive_path= $article_html_file_archive_path=
#    ../archives/2024/20240914_tstl_181536.html
# echo article_text_file_path= $article_text_file_path
#    ../archives/2024/20240914_tstl_181536.txt
#    20240914_tstl_181529.txt



for fd in "$codefiles_src_dir" "$codefiles_html_dir"  "$zipfile"  "$article_html_file" "$article_text_file" ; do
    [ -n "$fd" ] || continue
    [ -e "$fd" ] || continue

    if [ -n "$opt_overwrite" ]; then
        rm -rf "$fd"
    else
        die "Err: file/folder $fd already exist, overwrite with -w|--overwrite"
    fi
done

mkdir -p "$codefiles_src_dir"


article_text_tempfile_blog=
if [ -n "$archive_path" ] ; then
    article_text_tempfile_blog="$(mktemp /tmp/article_text_file_blog.XXXXXX)"
    [ -n "$article_text_tempfile_blog" ] || die "Err: no article_text_tempfile_blog"
fi


first_line="$(head -1 "$readme")"

print_first_line(){
    local codefiles_html_path="${1:-}"
    [ -n "$codefiles_html_path" ] || die "Err: no codefiles_html_path"

    case "$first_line" in
        ---|'% '*)  
            perl ~/kits/toolkit/tools/proli/noproli.pl -v  -w -c "$codefiles_html_path" weave "$readme"
            ;;
        *) 
            title="$(perl -e '$ARGV[0] =~ s/^#\s*//g; print $ARGV[0]' "$first_line")" 
            [ -n "$title" ] || die "Err: could not set title"

            echo "% $title"
            echo "% $last_edit_readme"
            echo ""

            # prints the readme without the first and the line
            # possible === line and following empty lines are not printed either

            perl ~/kits/toolkit/tools/proli/noproli.pl -v -w -c "$codefiles_html_path" weave "$readme" | perl -ne 'BEGIN{$s=0}; if($.==1){ next }elsif($. == 2){ next if /^[\s=]*$/}; if($s){print $_}else{unless(/^\s*$/){$s=1; print $_; }}' 

            
            ;;
    esac

    echo ""
    echo ""
    echo "## Sources"
}


if [ -n "$archive_path" ] ; then
    print_first_line  "$codefiles_html_dir_archive_path"  > "$article_text_tempfile_blog"
fi

print_first_line  "$codefiles_html_dir"  > "$article_text_file"

handle_file(){
    local bfile="${1:-}"
    [ -n "$bfile" ] || die "Err: bfile is empty"

    local file="${2:-}"
    [ -n "$file" ] || die "Err: file is empty"

    if [ ! -f "$file" ]; then 
        Warn "file '$file' not exists"
        return 1
    fi
    local htmlfile=
    case "$bfile" in
        *.html) htmlfile="$bfile" ;;
        *) htmlfile="$bfile.html" ;;
    esac

    local codefiles_html_path="${3:-}"
    [ -n "$codefiles_html_path" ] || die "Err: codefiles_html_path is empty"

    echo " "
    echo "* $bfile ([html]($codefiles_html_path/$htmlfile)|[raw]($codefiles_html_path/$bfile))"
}

handle_file_printer(){
    local file="${1:-}"

    local bfile="${file##*/}"

    case "$bfile" in
        "$outname"*) die "Err: please no file name with outname '$outname'";;
        *.zip|*.tar.gz) 
            warn "Fileitem $bfile not valid"
            continue
        ;;
        *) :   ;;
    esac

    [ -f "$codefiles_src_dir/$bfile" ] && die "Err: already exists '$codefiles_src_dir/$bfile'"
    cp "$file" "$codefiles_src_dir"/$bfile

    if [ -n "$archive_path" ] ; then
        handle_file "$bfile" "$file" "$codefiles_html_dir_archive_path"  >> "$article_text_tempfile_blog"
    fi

    handle_file "$bfile" "$file" "$codefiles_html_dir"  >> "$article_text_file"
}


if [ -n "$sourcedir" ] ; then
    [ -d "$sourcedir" ] || die "Err: sourcedir '$sourcedir' not exists"
    for file in "$sourcedir"/* ; do handle_file_printer "$file"; done
else
    for file in $@ ; do  handle_file_printer "$file";  done
fi 

cp "$readme" "$codefiles_src_dir" || die "Err: could not copy readme"


print_ending(){
    local root_path="${1:-}"
    [ -n "$root_path" ] || die "Err: root_path missing"

    echo ""
    echo "## Download"
    echo ""

    echo "[$zipfile]($root_path/$zipfile)" 

    echo "  "
    echo '---'
    echo "  "
    echo "* article source: [$article_text_file]($root_path/$article_text_file)" 
    [ -n "$last_edit_datetime" ] && echo "* last edited code:  $last_edit_datetime  "
    echo "* timestamp/id:   $now_date_daytime/$now_stamp_daytime"
}

if [ -n "$archive_path" ] ; then
    print_ending  "$archive_path"  >> "$article_text_tempfile_blog"
    echo "* archived article:  [$article_html_file_archive]($article_html_file_archive_path)" >> "$article_text_tempfile_blog"
fi

print_ending "."  >> "$article_text_file"


markdown_to_html(){
    local from="${1:-}"
    [ -n "$from" ] || die "Err: no from file"
    [ -f "$from" ] || die "Err: no valid from file"

    local to="${2:-}"
    [ -n "$to" ] || die "Err: no to file"

    [ -n "$opt_verbose" ] && echo "pandoc  --from=markdown -s '$from' > '$to'"
    pandoc  --from=markdown -s "$from" > "$to"
}

if [ -n "$archive_path" ] ; then
    [ -f "$article_text_file" ] || die "Err: no article_text_file '$article_text_file'"
    markdown_to_html "$article_text_tempfile_blog" "$article_html_file"
    markdown_to_html "$article_text_file"  "$article_html_file_archive"
else
    markdown_to_html "$article_text_file"  "$article_html_file"
fi


rm -f "$zipfile"
zip -r  $zipfile "$codefiles_src_dir" 

for file in "$codefiles_src_dir"/*; do
    [ -f "$file" ] || continue
    bfile="${file##*/}"
    case "$bfile" in
        *.html) : ;;
        *.md) 
            htmlfile="$file".html
            pandoc -s --metadata title="$bfile"  "$file" > "$htmlfile" || die "Err pandoc failed"
            ;;
        *)
            htmlfile="$file".html
            src2html "$file" >  "$htmlfile" || die "Err src2html failed"
            ;;
    esac
done


if [ -f "$article_html_file" ] ; then
    echo "OK: written to $article_html_file" 
else
    die "Err: could no write to $article_html_file"
fi


