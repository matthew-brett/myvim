#!python
""" Python makefile for windows sort-of making """

import os
from os.path import join as pjoin, dirname, expanduser, isfile, isdir
import sys
from shutil import copyfile, copytree, rmtree
from subprocess import check_call

HERE = dirname(__file__)
HOME = expanduser('~')
VIMBACKUP = pjoin(HOME, '_backup_vimfiles')

def backupdir():
    try:
        os.mkdir(VIMBACKUP)
    except (WindowsError, IOError, OSError):
        pass


def git_init():
    # Get the submodules
    check_call('git submodule update --init', shell=True)
    cwd = os.getcwd()
    try:
        os.chdir(pjoin('bundle', 'pyflakes'))
        check_call('git submodule update --init', shell=True)
    finally:
        os.chdir(cwd)


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
        rmtree(out_vim)
    os.mkdir(out_vim)
    # Copy all directories except .gits
    for sdir in os.listdir(in_vim):
        if sdir.startswith('.'):
            continue
        in_dir = pjoin(in_vim, sdir)
        if not isdir(in_dir):
            continue
        out_dir = pjoin(out_vim, sdir)
        copytree(in_dir, out_dir, ignore=ignore_gits)


def ignore_gits(src, names):
    if '.git' in names:
        return ['.git']
    return []


def main():
    try:
        target = sys.argv[1]
    except IndexError:
        target = 'vimfiles'
    if target == 'vimfiles':
        backupdir()
        git_init()
        vimfiles()
    else:
        raise RuntimeError('Confused by target "%s"' % target)


if __name__ == '__main__':
    main()
