" reStructuredText sections plugin
" Language:     Python (ft=python)
" Maintainer:   Matthew Brett
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://github.com/mathew-brett/myvim
"
" I got the structure of this plugin from
" http://github.com/nvie/vim-rst-tables by Vincent Driessen
" <vincent@datafox.nl>, with thanks.

" Only do this when not done yet for this buffer
if exists("g:loaded_rst_sections_ftplugin")
    finish
endif
let loaded_rst_sections_ftplugin = 1

python << endpython

import vim

import sys
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
    return line == char0 * len(line)


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


# Transitions between sections.  From Sphinx python doc hierarchy.
STATE_SEQ = (
    ('#', True),
    ('*', True),
    ('=', False),
    ('-', False),
    ('^', False),
    ('"', False),
    ('#', True))
NEXT_STATES = dict([(None, STATE_SEQ[0])] + zip(STATE_SEQ[:-1], STATE_SEQ[1:]))
PREV_STATES = dict([(None, STATE_SEQ[0])] + zip(STATE_SEQ[1:], STATE_SEQ[:-1]))


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
        below_no = line_no+1
        buf.append(underline, below_no)
    if not above_no is None:
        if above:
            buf[above_no] = underline
        else:
            del buf[above_no]
            below_no -= 1
    elif above: # no above underlining and need some
        buf.append(underline, line_no)
        return below_no + 1
    return below_no


def last_section(buf, line_no):
    """ Find previous section, return line number, char, above flag

    Parameters
    ----------
    buf : sequence
        sequence of strings
    line_no : int
        element in sequence in which to start back search

    Returns
    -------
    txt_line_no : None or int
        line number of last section text, or None if none found
    char : None or str
        Character of section underline / overline or None of none found
    above_flag : None or bool
        True if there is an overline, false if not, None if no section found
    """
    curr_no = line_no
    while curr_no > 0: # Need underline AND text to make section
        line = buf[curr_no]
        curr_no -= 1
        if len(line) == 0:
            continue
        if not is_underline(line):
            continue
        txt_line = buf[curr_no]
        if len(txt_line) == 0 or is_underline(txt_line):
            # could recurse in this case, but hey
            continue
        # We definitely have a section at this point.  Is it overlined?
        txt_line_no = curr_no
        char = line[0]
        if curr_no == 0:
            above = False
        else:
            over_line = buf[curr_no-1]
            above = is_underline(over_line) and over_line[0] == char
        return txt_line_no, char, above
    return None, None, None


def add_underline(char, above=False):
    line_no, below_no, above_no, buf = current_lines()
    curr_line = ul_from_lines(line_no, below_no, above_no, buf, char, above)
    vim.current.window.cursor = (curr_line+1, 0)


def section_cycle(cyc_func):
    """ Cycle section headings using section selector `cyc_func`

    Routine selects good new section heading type and inserts it into the
    buffer at the current location, moving the cursor to the underline for the
    section.

    Parameters
    ----------
    cyc_func : callable
        Callable returns section definition of form (char, overline_flag),
        where ``overline_flag`` is a bool specifying whether this section type
        has an overline or not.  Input to ``cyc_func`` is the current section
        definition, of the same form, or None, meaning we are not currently on
        a section, in which case `cyc_func` should return a good section to
        use.
    """
    line_no, below_no, above_no, buf = current_lines()
    if below_no is None:
        # In case of no current underline, use last, or first in sequence if
        # no previous section found
        _, char, above = last_section(buf, line_no-1)
        if char is None:
            char, above = cyc_func(None)
    else: # There is a current underline, cycle it
        current_state = (buf[below_no][0], not above_no is None)
        try:
            char, above = cyc_func(current_state)
        except KeyError:
            return
    curr_line = ul_from_lines(line_no, below_no, above_no, buf, char, above)
    vim.current.window.cursor = (curr_line+1, 0)


@bridged
def rst_section_reformat():
    line_no, below_no, above_no, buf = current_lines()
    if below_no is None:
        return
    above = not above_no is None
    char = buf[below_no][0]
    curr_line = ul_from_lines(line_no, below_no, above_no, buf, char, above)
    vim.current.window.cursor = (curr_line+1, 0)


@bridged
def rst_section_down_cycle():
    section_cycle(lambda x : NEXT_STATES[x])


@bridged
def rst_section_up_cycle():
    section_cycle(lambda x : PREV_STATES[x])


endpython

" Add mappings, unless the user didn't want this.
" The default mapping is registered, unless the user remapped it already.
if !exists("no_plugin_maps") && !exists("no_rst_sections_maps")
    if !hasmapto('RstSectionDownCycle(')
        noremap <silent> <leader><leader>d :call RstSectionDownCycle()<CR>
    endif
    if !hasmapto('RstSectionUpCycle(')
        noremap <silent> <leader><leader>u :call RstSectionUpCycle()<CR>
    endif
    if !hasmapto('RstSectionReformat(')
        noremap <silent> <leader><leader>r :call RstSectionReformat()<CR>
    endif
endif
