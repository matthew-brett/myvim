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


def line_under_over(buf, line_no):
    """ Return line number of text, underline and overline from `buf`

    Consider also the case where the suggested line number `line_no` in fact
    points to an underline or overline.  If the line at line_no looks like an
    underline, and the text in the line above does not, and is not blank, then
    assume we are on an underline.  Otherwise check the line below in similar
    criteria, if that passes we are on an overline.  In each case, move the
    estimated line number to the detected text line.

    Parameters
    ----------
    buf : sequence
        sequence of lines
    line_no : int
        line number in `buf` in which to look for text with underline and overline

    Returns
    -------
    line_no : int
        detected text line
    under_line : None or int
        detected underline line number (None if not detected)
    over_line : None or int
        detected overline line number (None if not detected)
    """
    line = buf[line_no]
    try:
        below = buf[line_no+1]
    except IndexError:
        below = None
    if is_underline(line):
        moved = False
        # Could be underline or overline; check for underline
        if not line_no == 0:
            above = buf[line_no-1]
            if len(above) > 0 and not is_underline(above):
                line_no -= 1
                below = line
                line = above
                moved = True
        if not moved: # check for overline
            # If below doesn't seem to be text, bail
            if below is None or len(below) == 0 or is_underline(below):
                return line_no, None, None
            try:
                below2 = buf[line_no+2]
            except IndexError: # at end of buffer
                # no matching underline
                return line_no, None, None
            if (not is_underline(below2) or line[0] != below2[0]):
                # no matching underline
                return line_no, None, None
            return line_no+1, line_no+2, line_no
    elif below is None or not is_underline(below):
        # Not on an underline, but below isn't an underline either
        return line_no, None, None
    if line_no == 0:
        return line_no, 1, None
    above = buf[line_no-1]
    if is_underline(above) and above[0] == below[0]:
        return line_no, line_no+1, line_no-1
    return line_no, line_no+1, None


# Transitions between section headings.  From Sphinx python doc hierarchy.
NEXT_STATES = {0: ('#', True),
               ('#', True): ('*', True),
               ('*', True): ('=', False),
               ('=', False): ('-', False),
               ('-', False): ('^', False),
               ('^', False): ('"', False),
               ('"', False): ('#', True)}


def current_lines():
    row, col = vim.current.window.cursor
    buf = vim.current.buffer
    line_no, below_no, above_no = line_under_over(buf, row-1)
    return line_no, below_no, above_no, buf


def ul_from_lines(line_no, below_no, above_no, buf, char, above=False):
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


def add_underline(char, above=False):
    line_no, below_no, above_no, buf = current_lines()
    ul_from_lines(line_no, below_no, above_no, buf, char, above)


@bridged
def rst_top_section():
    char, above = NEXT_STATES[0]
    add_underline(char, above)


@bridged
def rst_section(char):
    add_underline(char)


@bridged
def rst_section_reformat():
    line_no, below_no, above_no, buf = current_lines()
    if below_no is None:
        return
    above = not above_no is None
    char = buf[below_no][0]
    ul_from_lines(line_no, below_no, above_no, buf, char, above)


@bridged
def rst_section_cycle():
    line_no, below_no, above_no, buf = current_lines()
    if below_no is None:
        current_state = 0
    else:
        current_state = (buf[below_no][0], not above_no is None)
    try:
        char, above = NEXT_STATES[current_state]
    except KeyError:
        return
    ul_from_lines(line_no, below_no, above_no, buf, char, above)



endpython

" Add mappings, unless the user didn't want this.
" The default mapping is registered, unless the user remapped it already.
if !exists("no_plugin_maps") && !exists("no_rst_headings_maps")
    if !hasmapto('RstTopSection(')
        noremap <silent> <leader><leader>a :call RstTopSection()<CR>
    endif
    if !hasmapto('RstSection(')
        noremap <silent> <leader><leader>s :call RstSection("=")<CR>
    endif
    if !hasmapto('RstSectionEq(')
        noremap <silent> <leader><leader>= :call RstSection("=")<CR>
    endif
    if !hasmapto('RstSectionPlus(')
        noremap <silent> <leader><leader>+ :call RstSection("+")<CR>
    endif
    if !hasmapto('RstSectionDash(')
        noremap <silent> <leader><leader>- :call RstSection("-")<CR>
    endif
    if !hasmapto('RstSectionTilde(')
        noremap <silent> <leader><leader>~ :call RstSection("~")<CR>
    endif
    if !hasmapto('RstSectionCycle(')
        noremap <silent> <leader><leader>d :call RstSectionCycle()<CR>
    endif
    if !hasmapto('RstSectionReformat(')
        noremap <silent> <leader><leader>r :call RstSectionReformat()<CR>
    endif
endif
