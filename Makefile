# Makefile for vim directory

all: allhelp command-t

command-t:
	git submodule update --init
	cd bundle/command-t/ruby/command-t && ruby extconf.rb && make

allhelp:
	vim -c "call pathogen#helptags() | q"

helpfor-%:
	vim -c 'helptags bundle/$*/doc | q'

links:
	- mkdir ~/.vim_backup
	- mv ~/.vimrc ~/.vim_backup
	- rm -rf ~/.vim_backup/.vim
	- mv ~/.vim ~/.vim_backup
	ln -s $(CURDIR)/vimrc ~/.vimrc
	ln -s $(CURDIR) ~/.vim

.PHONY: helpfor
