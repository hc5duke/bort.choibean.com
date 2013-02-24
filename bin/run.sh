if [ "$1" == "-n" ]; then
  echo "(no compression mode)"
else
  if [ "$1" == "" ]; then
    echo "(normal mode)"
  else
    echo "Options:"
    echo " -n no compression"
    exit
  fi
fi

# Compile SASS
sass bart.scss -t compressed > bart.css

# Compile Coffeescript
coffee -p -c bart.coffee | sed '1 c\' > bart.js

if [ "$1" != "-n" ]; then
  # Compress Javascript
  yuicompressor -o bart.js bart.js

  # Compile HAML with compression
  haml bart.haml | perl -pe 's/^ +|\n+/ /g' | perl -pe 's/ +/ /g' | perl -pe 's/> </></g' | perl -pe 's/ $//g'> out/bart.html
else
  # Compile HAML without compression
  haml bart.haml > out/bart.html
fi

# Clean up
rm bart.js bart.css
