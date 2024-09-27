Writing about Code with proli
=============================

Be it a blog article about whatever piece of code, or writing some documentation.
Often there is some intertwining between code and text going on.

Examples:

- showing an extract of source code and writing about it
- even writing entire code files on the article, ready to be used
- etc.


That intertwining is tiring. I'm tired. So that is all for now.

I intend to write about the `proli` tools another time on my blog ...


Here is how the doc file for this project is generated:

```
sh ./proliblog.sh --suffix  readme.md noproli.pl
```


## proligen

Is driven by text files which are written as complementary files for source
code. You input an text article and a bunch of code files and you receive a
generated html file which all the necessary link and eventually also a folder
with source files and a zip file.

# noproli

A tool in the spirit of noweb. The only input a text files written in a literal
programming fashion





