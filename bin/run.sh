coffee -p -c bart.coffee | sed '1 c\' | perl -pe 's/^ +|\n//g' > bart.js
sass bart.scss -t compressed > bart.css
haml bart.haml | perl -pe 's/^ +|\n+/ /g' | perl -pe 's/ +/ /g' | perl -pe 's/> </></g' | perl -pe 's/ $//g'> out/bart.html
# haml bart.haml | perl -pe 's/^ +//g' | perl -pe 's/ +/ /g' | perl -pe 's/> </></g' | perl -pe 's/ $//g'> out/bart.html
rm bart.js bart.css
