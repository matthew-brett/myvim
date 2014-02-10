" Many settings here from http://nvie.com/posts/how-i-boosted-my-vim
" This must be first, because it changes other options as side effect. In fact
" nocompatible is set just by the loading of a vimrc file, but not if the file
" is loaded with the command line -u file and other circumstances, so this is
" belt-and-braces
set nocompatible
" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#runtime_append_all_bundles() 
" change the mapleader from \ to ,
let mapleader=","
" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
" Allow hiding of changed buffers
set hidden
" Use syntax
syntax on
" turn on indentation and filetypes
filetype plugin indent on
" set filename autocompletion to be bash-like
set wildmode=longest:full,full
set wildmenu
" Turn off everything gui
set guioptions=c
" Colors
if &t_Co >= 256 || has("gui_running")
   colorscheme mustang
endif
if &t_Co > 2 || has("gui_running")
   " switch syntax highlighting on, when the terminal has colors
   syntax on
endif
" Incrementral (smart) search
set incsearch
set ignorecase
set smartcase
set hlsearch      " highlight search terms
" Make sure I have at least a few lines of context when editing
set scrolloff=2
" Expand tabs by default
set expandtab
" Fancy statusbar from:
" http://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
" Other settings from boosted-vim page (link above)
set nowrap        " don't wrap lines
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set smarttab      " insert tabs on the start of a line according to
                  "    shiftwidth, not tabstop
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
" No temporary files while editing
set nobackup
set noswapfile
" Vim can highlight whitespaces for you in a convenient way:
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
" Not for html, xml
autocmd filetype html,xml set listchars-=tab:>.
" Clear highlighting of last search result
nmap <silent> ,/ :nohlsearch<CR>
" After testing for while, I decided not to
" Use semicolon as well as colon for command mode
" nnoremap ; :
" While learning - disable cursor keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
" From http://www.derekwyatt.org/vim/the-vimrc-file/my-vimrc-file/
" allow command line editing like emacs - see also help for emacs-keys
cnoremap <C-A>      <Home>
" These I use the cursor keys for; ctrl-F is the command line window anyway
" cnoremap <C-B>      <Left>
" cnoremap <C-F>      <Right>
cnoremap <C-N>      <Down>
cnoremap <C-P>      <Up>
cnoremap <ESC>b     <S-Left>
cnoremap <ESC><C-B> <S-Left>
cnoremap <ESC>f     <S-Right>
cnoremap <ESC><C-F> <S-Right>
cnoremap <ESC><C-H> <C-W>
" Maps to make handling windows a bit easier
noremap <silent> ,h :wincmd h<CR>
noremap <silent> ,j :wincmd j<CR>
noremap <silent> ,k :wincmd k<CR>
noremap <silent> ,l :wincmd l<CR>
noremap <silent> ,sb :wincmd p<CR>
noremap <silent> ,w :wincmd w<CR>
noremap <silent> ,x :wincmd x<CR>
noremap <silent> <C-F9>  :vertical resize -10<CR>
noremap <silent> <C-F10> :resize +10<CR>
noremap <silent> <C-F11> :resize -10<CR>
noremap <silent> <C-F12> :vertical resize +10<CR>
noremap <silent> ,s8 :vertical resize 83<CR>
noremap <silent> ,cj :wincmd j<CR>:close<CR>
noremap <silent> ,ck :wincmd k<CR>:close<CR>
noremap <silent> ,ch :wincmd h<CR>:close<CR>
noremap <silent> ,cl :wincmd l<CR>:close<CR>
noremap <silent> ,cc :close<CR>
noremap <silent> ,cw :cclose<CR>
noremap <silent> ,ml <C-W>L
noremap <silent> ,mk <C-W>K
noremap <silent> ,mh <C-W>H
noremap <silent> ,mj <C-W>J
noremap <silent> <C-7> <C-W>>
noremap <silent> <C-8> <C-W>+
noremap <silent> <C-9> <C-W>+
noremap <silent> <C-0> <C-W>>
" From http://dancingpenguinsoflight.com/2009/02/python-and-vim-make-your-own-ide
" Toggle line numbers and fold column for easy copying:
nnoremap <silent> ,po :set nonumber!<CR>:set foldcolumn=0<CR>
" Just toggle line numbers
nnoremap <silent> ,nn :set nonumber!<CR>
" Spelling
set spelllang=en_us
" Syntax sync
" http://vim.wikia.com/wiki/Fix_syntax_highlighting
nnoremap <silent> ,ss :syntax sync fromstart<CR>
" Light, dark background shortcuts
com! -nargs=* -count=0	LightBG colorscheme pyte
com! -nargs=* -count=0	DarkBG colorscheme mustang
" Setting the gui font - from help setting-guifont
if has("gui_running")
    if has("gui_win32")
        :set guifont=Lucida_Console:h11:cANSI
    endif
endif
" Python omnicompletion
autocmd FileType python set omnifunc=pythoncomplete#Complete
" Join all lines within paragraph
" Modified from
" http://stackoverflow.com/questions/5651454/vim-join-all-lines-in-paragraph
nnoremap <silent> ,ll :%s/\(\S\)\n\(\S\)/\1 \2/<CR>:nohlsearch<CR>
" =================================
"  configure plugins
" =================================
" Set yankring history file
let g:yankring_history_file = '.yankring_history'
" Supertab
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType="<c-x><c-o>"
" Chapa function / class / method movement
let g:chapa_default_mappings = 1
