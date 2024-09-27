# perl -w -n 
#
# compresses a perl script to a oneliner
#

#
#

chomp; 

# omits all comments
if(/^\s*\#/){
    next;
};

# omits all empty lines
if(/^\s*$/){
    next;
}
s/'/'\\''/g;

# remove all whitespace outside of quoted parts and outside of s/kk/g
# regexes
my(@line)=  split(/("[^"]*"|q\[[^\]]*\]|s\/.*\/g)/);
#my(@line)= map { split(/(s\/[^\/]*\/[^\/]*\/g)/) }  split(/("[^"]*")/);
for(@line){
    unless(/^"|^s\/|^q\[/){
        s/[\s\t]+//g
    }
    print
} 


