install-dotfiles.sh - rules applied by the installation script: 

Either the contents (files) or the directory itself (.dir) is linked into ~/.

- fubar.dir -> the entire folder is linked to ~/.fobar




- quoobar.files -> the files linked to ~/.quoobar

    - if the folder doesnt' exists, then the folder is created


Uppercase strings in folder names (HOME,USER,...) are interpreted as
environment variables



- Folder with the ending '.f' or '.file' have their folder name ignored
    The files ar simply linked to ~/.
    Examples: dot.files

- Folder with a dash, are (reverse) nested

-    Examples: autoload-vim.files -> ~/.vim/autoload/

- Uppercase is eventually evaluated as env variable

    Examples: USER.files => ~/.frankie
    Examples: HOME.files => /Users/frankie/. 

- Folder with the ending '.l' or '.link' are linked to ~/.
    Examples: bin.l







