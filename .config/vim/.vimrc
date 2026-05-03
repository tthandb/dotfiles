" =============================================================================
" .vimrc — simplified port of ../nvim/ for traditional Vim 9+
" Plugins live in ~/.vim/pack/plugins/start/ (run install.sh to populate)
" =============================================================================

" === LEADER & ENCODING =======================================================
let mapleader = " "
set encoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8

" === DISPLAY =================================================================
set number relativenumber
set cursorline
set termguicolors
set background=dark
set nowrap
set ruler
set showtabline=2
set laststatus=2
set cmdheight=2
set pumheight=10
set conceallevel=0
syntax enable
filetype plugin indent on

" === INDENT ==================================================================
set tabstop=2 shiftwidth=2
set expandtab smarttab
set autoindent smartindent

" === SEARCH ==================================================================
set hlsearch incsearch
set ignorecase smartcase

" === SPLITS ==================================================================
set splitbelow splitright

" === FOLDING =================================================================
set foldmethod=indent
set foldlevelstart=99
set nofoldenable

" === MISC ====================================================================
" ensure spawned commands (fzf/rg/git) find Homebrew binaries
let $PATH = '/opt/homebrew/bin:/usr/local/bin:' . $PATH

set hidden
set mouse=a
set updatetime=300
set timeoutlen=500
set clipboard=unnamed,unnamedplus
set backspace=indent,eol,start
set noerrorbells novisualbell
set nobackup nowritebackup noswapfile
set undofile
set undodir=~/.vim/undo
set signcolumn=yes

" disable netrw — NERDTree handles file browsing
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" ensure undodir exists
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif

" === AUTOCMDS ================================================================
" disable comment continuation (ftplugins re-add cro, so setlocal per FileType)
augroup vimrc_formatoptions
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" highlight-on-yank handled by vim-highlightedyank
let g:highlightedyank_highlight_duration = 200

" === BASE KEYMAPS ============================================================
" Esc alternatives
inoremap jk <Esc>
inoremap kj <Esc>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move lines (Alt-j/k)
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

" Keep selection after indent
vnoremap < <gv
vnoremap > >gv

" Sessions (replace auto-session)
nnoremap <leader>ws :mksession! Session.vim<CR>
nnoremap <leader>wr :source Session.vim<CR>

" === PLUGIN: tokyonight ======================================================
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1

" === PLUGIN: airline =========================================================
let g:airline_theme = 'tokyonight'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_tabs = 1

" === PLUGIN: NERDTree ========================================================
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 40
augroup vimrc_nerdtree
  autocmd!
  autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | quit | endif
augroup END

" === PLUGIN: fzf =============================================================
let g:fzf_layout = { 'down': '40%' }

" Pick file-list + grep backends based on what's available.
" Santa-blocked machines (no brew binaries) fall back to git/find/grep — all
" come with macOS or git itself, so they're always allowed.
if executable('rg')
  let $FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!**/.git/*'"
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>),
    \   1, fzf#vim#with_preview(), <bang>0)
elseif executable('git')
  " git ls-files: respects .gitignore; outside a repo it returns nothing,
  " so combine with find as a fallback for non-repo dirs.
  let $FZF_DEFAULT_COMMAND = "(git ls-files --cached --others --exclude-standard 2>/dev/null || find . -type f -not -path '*/.git/*')"
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'git grep --line-number --color=always --no-color '.shellescape(<q-args>).' || grep -rn --color=never --exclude-dir=.git '.shellescape(<q-args>).' .',
    \   1, fzf#vim#with_preview(), <bang>0)
else
  let $FZF_DEFAULT_COMMAND = "find . -type f -not -path '*/.git/*'"
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'grep -rn --color=never --exclude-dir=.git '.shellescape(<q-args>).' .',
    \   1, fzf#vim#with_preview(), <bang>0)
endif

" === PLUGIN: gitgutter =======================================================
let g:gitgutter_sign_added              = '+'
let g:gitgutter_sign_modified           = '~'
let g:gitgutter_sign_removed            = '-'
let g:gitgutter_sign_removed_first_line = '-'
let g:gitgutter_sign_modified_removed   = '~'

" === PLUGIN: sneak (leap-equivalent) =========================================
let g:sneak#label = 1
let g:sneak#s_next = 1

" === PLUGIN KEYMAPS: fzf =====================================================
nnoremap <silent> <leader>fn :Files<CR>
nnoremap <silent> <leader>fg :Rg<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fh :Helptags<CR>
nnoremap <silent> <leader>fr :History<CR>
nnoremap <silent> <leader>fR :Marks<CR>
nnoremap <silent> <leader>fk :Maps<CR>
nnoremap <silent> <leader>fc :Commands<CR>

" === PLUGIN KEYMAPS: NERDTree ================================================
nnoremap <silent> <C-b> :NERDTreeToggle<CR>
nnoremap <silent> <C-i> :NERDTreeFocus<CR>

" === PLUGIN KEYMAPS: git =====================================================
" fugitive
nnoremap <silent> <leader>gg :Git<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gl :Git blame<CR>
" gitgutter hunks
nmap <leader>gj <Plug>(GitGutterNextHunk)
nmap <leader>gk <Plug>(GitGutterPrevHunk)
nmap <leader>gp <Plug>(GitGutterPreviewHunk)
nmap <leader>gs <Plug>(GitGutterStageHunk)
nmap <leader>gr <Plug>(GitGutterUndoHunk)

" === COLORSCHEME (LAST) ======================================================
silent! colorscheme tokyonight
