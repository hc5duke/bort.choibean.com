coffee -p -c bart.coffee | sed '1 c\' | perl -pe 's/^ +|\n//g' > out/bart.js
haml bart.haml | perl -pe 's/^ +|\n+/ /g' | perl -pe 's/ +/ /g' | perl -pe 's/> </></g' | perl -pe 's/ $//g'> out/bart.html
