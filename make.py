#!python
""" Python makefile for windows sort-of making """

import os
from os.path import join as pjoin, dirname, expanduser, isfile, isdir
import sys
from shutil import copyfile, copytree, rmtree

HERE = dirname(__file__)
HOME = expanduser('~')
VIMBACKUP = pjoin(HOME, '_backup_vimfiles')

def backupdir():
    try:
        os.mkdir(VIMBACKUP)
    except (WindowsError, IOError):
        pass

def vimfiles():
    in_vimrc = pjoin(HERE, 'vimrc')
    out_vimrc = pjoin(HOME, '_vimrc')
    bak_vimrc = pjoin(VIMBACKUP, '_vimrc')
    if isfile(out_vimrc):
        if isfile(bak_vimrc):
            os.remove(bak_vimrc)
        copyfile(out_vimrc, bak_vimrc)
    copyfile(in_vimrc, out_vimrc)
    in_vim = HERE
    out_vim = pjoin(HOME, 'vimfiles')
    bak_vim = pjoin(VIMBACKUP, 'vimfiles')
    if isdir(out_vim):
        if isdir(bak_vim):
            rmtree(bak_vim)
        copytree(out_vim, bak_vim)
    copytree(in_vim, out_vim)


def main():
    try:
        target = sys.argv[1]
    except IndexError:
        raise RuntimeError('Need target to "make"')
    if target == 'vimfiles':
        backupdir()
        vimfiles()
    else:
        raise RuntimeError('Confused by target "%s"' % target)


if __name__ == '__main__':
    main()
