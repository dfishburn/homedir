#!/bin/sh

USAGE=\
'Description: This script will setup the environment with all 
the tools necessary to build a GUI vim.
If will only run, if it determines Vim has not been built
and installed yet.';

vimTestDir=/var/tmp/user$uid/vim8_from_git/vim8
if [ -d ${vimTestDir} ]; then
    echo "Vim8 has already been built and probably deployed:${vimTestDir}" 
    exit 0
fi

echo "Add some debian source code for building Vim (-n noclobber)"
cp -n /etc/apt/sources.list /etc/apt/sources.list.orig
sed -i '/^#\s*deb-src.*main.*/s/^#\s*//' /etc/apt/sources.list

echo "Fetching the updated packages based on updated source list"
apt-get update 

echo "Adding build dependency on vim-gnome to build a GUI for Vim"
apt-get build-dep -y vim-gnome

echo "If Vim python plugins are needed"
apt-get install -y python

echo "If Vim NodeJS plugins are needed"
apt-get install -y nodejs

echo "This script will fetch Vim from source"
echo "Compile it for GTK2"
echo "And support Perl / Python / Ruby scripts"
echo "NodeJS is supported through regular Vim scripts"
chmod +x vim8-install.sh
./vim8-install.sh -git --prefix=/usr --with-features=huge --enable-gui=gtk2 --enable-perlinterp=dynamic --enable-pythoninterp=dynamic --enable-rubyinterp=dynamic
