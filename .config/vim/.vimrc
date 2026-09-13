" compatibility
set nocompatible
set cpoptions&vim

" leader
let mapleader = " "
let maplocalleader = " "
set encoding=utf-8
scriptencoding utf-8

" display
set number relativenumber
set cursorline
set nowrap
set scrolloff=5
set sidescrolloff=8
set laststatus=2
set showtabline=1
set cmdheight=1
set pumheight=12
set display=truncate
set signcolumn=yes
set shortmess+=c
set lazyredraw
set background=dark
syntax enable
filetype plugin indent on

if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" indent
set tabstop=2 shiftwidth=2 softtabstop=2
set expandtab smarttab shiftround
set autoindent

" search
set hlsearch incsearch
set ignorecase smartcase

" splits, folds, diff
set splitbelow splitright
set foldmethod=indent
set foldlevelstart=99
set nofoldenable
silent! set diffopt+=vertical
silent! set diffopt+=internal
silent! set diffopt+=algorithm:histogram
silent! set diffopt+=indent-heuristic
silent! set diffopt+=inline:char

" files and undo
set hidden
set autoread
set nobackup nowritebackup noswapfile
set undofile
set undodir=$HOME/.vim/undo//
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p', 0700)
endif

" misc
set mouse=a
set updatetime=300
set timeout timeoutlen=500
set ttimeout ttimeoutlen=30
set backspace=indent,eol,start
set nrformats-=octal
set history=1000
set viminfo='500,<200,s64,h
set noerrorbells novisualbell t_vb=
set sessionoptions-=options
set sessionoptions-=folds
set virtualedit=block

augroup vimrc_format
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r
        \ formatoptions-=o formatoptions+=j
augroup END

" built-in packages
silent! packadd! matchit
silent! packadd! cfilter
silent! packadd! editorconfig

" file navigation
set path=.,,**
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set wildcharm=<C-z>
if has('patch-8.2.4325')
  silent! set wildoptions=pum,fuzzy
endif

set wildignore+=*/node_modules/*,*/.git/*,*/dist/*,*/build/*,*/target/*
set wildignore+=*/vendor/*,*/.venv/*,*/venv/*,*/__pycache__/*,*/coverage/*
set wildignore+=*.o,*.obj,*.pyc,*.class,*.jar,*.zip,*.gz,*.pdf
set wildignore+=*.png,*.jpg,*.jpeg,*.gif,*.ico,*.woff,*.woff2,*.ttf
set suffixesadd=.js,.jsx,.ts,.tsx,.mjs,.json,.py,.go,.rb,.java,.css,.scss

nnoremap <leader>f :find <C-z>
nnoremap <leader>b :buffer <C-z>

" grep
function! s:SetupGrep() abort
  if executable('git') && !empty(finddir('.git', getcwd() . ';'))
    let &grepprg = 'git grep -In --column --no-color --untracked $*'
    set grepformat=%f:%l:%c:%m
  else
    let &grepprg = 'grep -rnI --binary-files=without-match'
          \ . ' --exclude-dir=.git --exclude-dir=node_modules'
          \ . ' --exclude-dir=dist --exclude-dir=.venv $* .'
    set grepformat=%f:%l:%m
  endif
endfunction

call s:SetupGrep()
if exists('##DirChanged')
  augroup vimrc_grep
    autocmd!
    autocmd DirChanged * call s:SetupGrep()
  augroup END
endif

function! s:Grep(args) abort
  execute 'silent! grep! ' . a:args
  redraw!
  botright cwindow
endfunction
command! -nargs=+ -complete=file_in_path Grep call s:Grep(<q-args>)

nnoremap <leader>* :Grep <C-r><C-w><CR>
xnoremap <leader>* y:<C-u>execute 'Grep ' . shellescape(@")<CR>

" quickfix
nnoremap <silent> ]q :cnext<CR>zz
nnoremap <silent> [q :cprevious<CR>zz

augroup vimrc_qf
  autocmd!
  autocmd QuickFixCmdPost [^l]* botright cwindow
  autocmd FileType qf setlocal nonumber norelativenumber signcolumn=no
        \ | nnoremap <buffer> q :cclose<CR>
augroup END

" tags
set tags=./tags;,tags

function! s:Ctags() abort
  execute '!ctags -R --exclude=.git --exclude=node_modules'
        \ . ' --exclude=dist --exclude=build .'
  redraw!
endfunction
if executable('ctags')
  command! Ctags call s:Ctags()
endif

" completion
set complete=.,w,b,u,t,i
set completeopt=menuone,noinsert,noselect
set omnifunc=syntaxcomplete#Complete

" clipboard
set clipboard=

function! s:PbcopyOp(type) abort
  let l:save = @@
  silent execute 'normal! `[v`]y'
  call system('pbcopy', @@)
  let @@ = l:save
endfunction

if !has('clipboard') && executable('pbcopy')
  nnoremap <leader>y :set operatorfunc=<SID>PbcopyOp<CR>g@
  nnoremap <leader>Y yy:call system('pbcopy', @@)<CR>
  xnoremap <leader>y y:call system('pbcopy', @@)<CR>
  nnoremap <leader>p :let @@=system('pbpaste')<CR>p
endif

" keymaps
inoremap jk <Esc>

nnoremap <silent> <leader>/ :nohlsearch<CR>

nnoremap <silent> ]e :m .+1<CR>==
nnoremap <silent> [e :m .-2<CR>==
xnoremap <silent> ]e :m '>+1<CR>gv=gv
xnoremap <silent> [e :m '<-2<CR>gv=gv

xnoremap < <gv
xnoremap > >gv

inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ( (<C-g>u

command! W execute 'w !sudo tee % > /dev/null' <Bar> edit!
command! Trim keeppatterns %s/\s\+$//e

" autocmds
augroup vimrc_misc
  autocmd!
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$")
        \ && &filetype !~# 'commit' | execute "normal! g`\"" | endif
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter *
        \ if &number | setlocal relativenumber | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave *
        \ if &number | setlocal norelativenumber | endif
  autocmd VimResized * wincmd =
augroup END

if exists('##TerminalWinOpen')
  autocmd TerminalWinOpen * setlocal nonumber norelativenumber signcolumn=no
endif

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_localcopydircmd = 'cp -r'
nnoremap <silent> - :Explore<CR>

" fugitive
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

" statusline
function! StatuslineGit() abort
  if exists('*FugitiveHead')
    let l:head = FugitiveHead()
    return empty(l:head) ? '' : '  [' . l:head . ']'
  endif
  return ''
endfunction

set statusline=
set statusline+=\ %<%f\ %h%w%m%r
set statusline+=%{StatuslineGit()}
set statusline+=%=
set statusline+=%{&filetype}\ \ %{&fileformat}\ \ %l:%c\ \ %P\ 

" colorscheme
silent! colorscheme habamax

" project local
if filereadable('.vimlocal')
  source .vimlocal
endif
