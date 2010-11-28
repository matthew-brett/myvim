""" Tests for rst-headings

It's a bit nasty, but we pull out the python from the vim file, and test that

Run with nosetests
"""

import sys
from os.path import dirname, join as pjoin, split as psplit
import re
import imp

from nose.tools import assert_true, assert_false, assert_equal


THIS_DIR = dirname(__file__)
CODE_DIR, _ = psplit(THIS_DIR)
VIM_FILE = pjoin(CODE_DIR, 'rst_headings.vim')

# Pull python code out of vim file
_all_code = open(VIM_FILE).read()
_match = re.search(r"python << endpython(.*)endpython", _all_code, flags=re.DOTALL)
if not _match:
    raise RuntimeError('Could not find python code in file %s' % VIM_FILE)
PY_CODE = _match.groups()[0]

# Make something that looks like the vim module
assert "vim" not in sys.modules
sys.path.insert(0, THIS_DIR)
import fakevim
sys.modules["vim"] = fakevim
# And something that looks like the vim_bridge module.  This only needs to give
# a null decorator.
vim_bridge = imp.new_module('vim_bridge')
vim_bridge.bridged = lambda x : x
sys.modules['vim_bridge'] = vim_bridge

exec(PY_CODE)

def test_is_underline():
    for char in SECTION_CHARS:
        for n in range(1,4):
            line = char * n
            assert_true(is_underline(line))
    assert_false(is_underline(''))
    assert_false(is_underline('aa'))
    assert_false(is_underline('+++=+'))


def test_line_is_underline():
    assert_equal(line_under_over([''], 0), (0, None, None))
    assert_equal(line_under_over(['Text'], 0), (0, None, None))
    assert_equal(line_under_over(['Text', 'Text2'], 0), (0, None, None))
    assert_equal(line_under_over(['Text', '===='], 0), (0, 1, None))
    # Do we find the text line when we pass the underline?
    assert_equal(line_under_over(['Text', '===='], 1), (0, 1, None))
    # Do we find the overline?
    assert_equal(line_under_over(['====', 'Text', '===='], 1), (1, 2, 0))
    # When we pass the under or overline?
    assert_equal(line_under_over(['====', 'Text', '===='], 2), (1, 2, 0))
    assert_equal(line_under_over(['====', 'Text', '===='], 0), (1, 2, 0))
    # Do we reject the underline if it's too short? No
    assert_equal(line_under_over(['Text', '==='], 0), (0, 1, None))
    assert_equal(line_under_over(['Text', '==='], 1), (0, 1, None))
    # Do we reject the overline if it's too short?
    assert_equal(line_under_over(['===', 'Text', '===='], 1), (1, 2, 0))
    assert_equal(line_under_over(['===', 'Text', '===='], 2), (1, 2, 0))
    assert_equal(line_under_over(['===', 'Text', '===='], 0), (1, 2, 0))


