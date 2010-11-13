# Makefile for vim directory

all: init allhelp

command-t:
	cd bundle/command-t/ruby/command-t && ruby extconf.rb && make

vim-rst-tables:
	easy_install -U vim_bridge

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

init: command-t vim-rst-tables

.PHONY: helpfor
