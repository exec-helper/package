#!/bin/bash

distribution=$(lsb_release --codename --short)
date='Tue, 30 May 2017 20:44:31 +0100'

echo "Generating changelog..."
cat << EOF > debian/changelog
exec-helper (0.1.0-1) ${distribution}; urgency=low

  * Initial release

 -- bverhagen <barrie.verhagen@gmail.com>  ${date}
EOF
