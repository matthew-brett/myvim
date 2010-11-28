" reStructuredText headings plugin
" Language:     Python (ft=python)
" Maintainer:   Matthew Brett
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://github.com/mathew-brett/myvim
"
" I got the structure of this plugin from
" http://github.com/nvie/vim-rst-tables by Vincent Driessen
" <vincent@datafox.nl>, with thanks.

" Only do this when not done yet for this buffer
if exists("g:loaded_rst_headings_ftplugin")
    finish
endif
let loaded_rst_headings_ftplugin = 1

python << endpython

import vim

from os.path import dirname

# get the directory this script is in: the vim_bridge python module should be
# installed there.
our_pth = dirname(vim.eval('expand("<sfile>")'))
sys.path.insert(0, our_pth)

import re
import textwrap

from vim_bridge import bridged

SECTION_CHARS=r"!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"


@bridged
def make_top_section():
    add_underline('=', above=True)
    return ''


@bridged
def make_section(char):
    add_underline(char)
    return ''


@bridged
def make_section_reformat():
    add_underline()
    return ''


def is_underline(line):
    if len(line) == 0:
        return False
    char0 = line[0]
    if not char0 in SECTION_CHARS:
        return False
    if len(line) == 1:
        return True
    non_match = [char for char in line[1:] if char != char0]
    return len(non_match) == 0


def line_is_underlined(buf, line_no):
    line = buf[line_no]
    try:
        below = buf[line_no+1]
    except IndexError:
        return line_no, None, None
    if not is_underline(below) or len(below) < len(line):
        return line_no, None, None
    if line_no == 0:
        return line_no, 1, None
    above = buf[line_no-1]
    if (is_underline(above) and
        above[0] == below[0] and
        len(below) == len(above)):
        return line_no, line_no+1, None
    return line_no, line_no+1, line_no-1


def add_underline(char=None, above=False):
    row, col = vim.current.window.cursor
    buf = vim.current.buffer
    line_no, below_no, above_no = line_is_underlined(buf, row-1)
    if char is None:
        if below_no is None:
            return
        char = buf[below_no][0]
    line = buf[line_no]
    underline = char * len(line)
    if not below_no is None:
        buf[below_no] = underline
    else:
        buf.append(underline, line_no+1)
    if not above_no is None:
        if above:
            buf[above_no] = underline
        else:
            del buf[above_no]
    elif above: # no above underlining and need some
        buf.append(underline, line_no)


endpython

" Add mappings, unless the user didn't want this.
" The default mapping is registered, unless the user remapped it already.
if !exists("no_plugin_maps") && !exists("no_rst_headings_maps")
    if !hasmapto('MakeTopSection(')
        noremap <silent> <leader><leader>a :call MakeTopSection()<CR>
    endif
    if !hasmapto('MakeSection(')
        noremap <silent> <leader><leader>s :call MakeSection("=")<CR>
    endif
    if !hasmapto('MakeSectionEq(')
        noremap <silent> <leader><leader>= :call MakeSection("=")<CR>
    endif
    if !hasmapto('MakeSectionPlus(')
        noremap <silent> <leader><leader>+ :call MakeSection("+")<CR>
    endif
    if !hasmapto('MakeSectionDash(')
        noremap <silent> <leader><leader>- :call MakeSection("-")<CR>
    endif
    if !hasmapto('MakeSectionTilde(')
        noremap <silent> <leader><leader>~ :call MakeSection("~")<CR>
    endif
    if !hasmapto('MakeSectionReformat(')
        noremap <silent> <leader><leader>r :call MakeSectionReformat()<CR>
    endif
endif
