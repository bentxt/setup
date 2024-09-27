
# for fast checks in scripts

if test -z $UNIVERSAL_BIN_GFIND
    set -xU UNIVERSAL_BIN_GFIND (command -v gfind)
end

# realpath resolves all levels of symbolic links, alternatives:
#  - readlink -f
#  - perl (perl -MCwd -e 'print Cwd::abs_path shift' ga.txt)
if test -z UNIVERSAL_BIN_REALPATH
    set -xU UNIVERSAL_BIN_REALPATH (command -v realpath)
end

if test -f $HOME/kit/vendor/mysqids.bash
    set -xU UNIVERSAL_BASH_MYSQIDS $HOME/kit/vendor/mysqids.bash
end

if test -z UNIVERSAL_BIN_MD5SUM
    set -xU UNIVERSAL_BIN_MD5SUM (command -v md5sum)
end

if test -z UNIVERSAL_HOST_OS
    set -xU UNIVERSAL_HOST_OS (uname | tr '[:upper:]' '[:lower:]')
end


