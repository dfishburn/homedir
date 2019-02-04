To build a fresh copy of Vim

Get required compiler libraries in 3 steps:

" See below but you must first uncomment the # deb-src lines in /etc/apt/sources.list
sudo http_proxy=http://proxy.ykf.sap.corp:8080 apt-get update
sudo http_proxy=http://proxy.ykf.sap.corp:8080 apt-get build-dep vim-gnome
sudo http_proxy=http://proxy.ykf.sap.corp:8080 apt-get install build-essentials git vim-gnome libncurses5-dev libncursesw5-dev

Or as separate steps:
sudo apt-get build-dep vim
sudo apt-get build-dep vim-gnome
sudo apt-get install git 
sudo apt-get install vim-gnome
sudo apt-get install libncurses5-dev
sudo apt-get install libncursesw5-dev

Download source using Git, compile and put in the /usr space, not /user/local:

sudo ./vim8-install.sh -git --prefix=/usr --with-features=huge --enable-gui=auto --enable-gtk2-check --with-x --enable-perlinterp=dynamic --enable-pythoninterp=dynamic --enable-rubyinterp=dynamic

If gvim does not work (or is wrong version):
	/var/tmp/user0/vim8_from_git/vim8# ./configure --enable-gui | grep gui
		checking --enable-gui argument... no GUI support

/var/tmp/user0/vim8_from_git/vim8# apt build-dep vim
	Reading package lists... Done
	E: You must put some 'source' URIs in your sources.list

sudo apt-get update
If this does not fix the issue, edit /etc/apt/sources.list, e.g. using
sudo vim /etc/apt/sources.list
and ensure that the deb-src lines are not commented out.
sudo apt upgrade
sudo apt -get build-dep vim
sudo apt -get build-dep vim-gtk

root@DF-CFLOCAL:/var/tmp/user0/vim8_from_git/vim8# ./configure --enable-gui | grep gui
checking --enable-gui argument... no GUI support

apt build-dep vim-gtk
apt build-dep vim-gtk2
apt build-dep vim-gtk3




