# Makefile for vim directory

all: command-t snipmate

command-t:
	cd bundle/command-t/ruby/command-t && ruby extconf.rb && make
	vim -c "call pathogen#helptags() | q"

snipmate:
	vim -c 'helptags bundle/snipmate/doc | q'

links:
	- mkdir ~/.vim_backup
	- mv ~/.vimrc ~/.vim_backup
	- rm -rf ~/.vim_backup/.vim
	- mv ~/.vim ~/.vim_backup
	ln -s $(CURDIR)/vimrc ~/.vimrc
	ln -s $(CURDIR) ~/.vim

