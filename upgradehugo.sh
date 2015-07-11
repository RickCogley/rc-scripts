#!/bin/bash
# upgrade hugo

cd ~
echo Moving old hugo to hugo-prev
mv ~/gocode/bin/hugo ~/gocode/bin/hugo-prev
echo Updating hugo and its dependencies
go get -u -v github.com/spf13/hugo
echo Copying special Makefile so hash is included in filename
cp -f ~/dev/rc-scripts/hugo-Makefile ~/gocode/src/github.com/spf13/hugo/Makefile
echo Switch to hugo source folder and make
cd ~/gocode/src/github.com/spf13/hugo/
make
echo Move compiled file into place
mv ~/gocode/src/github.com/spf13/hugo/hugo-* ~/gocode/bin/
rm -rf ~/gocode/bin/hugo
cd ~/gocode/bin
echo Finally, manually make a symlink to new hugo in ~/gocode/bin
