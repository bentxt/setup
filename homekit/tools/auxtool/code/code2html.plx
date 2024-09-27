
# perl -n -l 
#
BEGIN{
    $lnr = 0;
foreach (q[<!DOCTYPE html>],
    q[<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">],
    q[<head>],
        q[<meta charset="utf-8">],
        q[<meta name="generator" content="pandoc">],
        q[<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">],
        "<title>$ARGV</title>",
        q[<style>html {color: #1a1a1a;background-color: #fdfdfd;}],q[h1, h2, h3, h4, h5, h6 {margin-top: 1.4em;}],
            q[table .lnr {],q[width:auto;text-align:right;white-space: nowrap}],
            q[table .src {width: 100%}],q[table {white-space: nowrap;border-collapse:collapse;border-spacing:0;width:100%;border: 1px solid;font-family: "Courier New", monospace;white-space: pre;}],
            q[tr { border: none; }],
            q[table tr td {border-right: 1px solid black;color: black}],
        q[</style>],
        q[</head>],
        q[<body>],
        "<h1>$ARGV</h1>",
            q[<table>],
            q[<tbody>]) {
            print($_ );
        };
};

chomp;
$lnr++;
s/&/\&amp;/g; 
s/</\&lt;/g; 
s/>/\&gt;/g; 
s/"/\&quot;/g; 
s/'"'"'/\&#39;/g;
print(q[<tr><td id="] . $lnr . q[" class="lnr" >] . $lnr . q[</td>]);
print(q[  <td class="src" >] . $_ . "</td></tr>\n"); 

END{
foreach (qw[</tbody> </table> </body> </html>]){ print($_) };
}

