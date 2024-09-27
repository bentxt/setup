

my $str = q[s/&/\&amp;/g; s/</\&lt;/g  x;x s/>/\&gt;/g x;x s/"/\&quot;/g x;x s/'\''"'\''"'\''/\&#39;/g];
#my(@line)=  split(/(s\/.*\/g)/, $str);
my(@line)=  split(/("[^"]*"|q\[[^\]]*\]|s\/[^\/]*\/g|\/[^\/]*\/g)/, $str);



 foreach (@line){ 
     if ($_ =~ /^"|^s\/|^\q\[/) {
         print XXXX => $_  . "\n"; 
     }else{
         print YYYY => $_  . "\n"; 
     }
 }
