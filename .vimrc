set nocompatible            " Disable compatibility with vi which can cause unexpected issues
filetype on                 " Enable type file detection.
filetype plugin on          " Enable plugins and load plugin for the detected file type
filetype indent on          " Load an indent file for the detected file type.
set number relativenumber   " Show line numbers
" set number relativenumber autocmd FocusLost * set nocursorline colorcolumn=0 norelativenumber autocmd FocusGained * set cursorline colorcolumn=+0 relativenumber
set hlsearch                " Highlight search 
set incsearch               " Incremental search
set tabstop=4               " Number of columns occupied by a tab 
set softtabstop=4           " See multiple spaces as tabstops so <BS> does the right thing
set expandtab               " Converts tabs to white space
set shiftwidth=4            " Width for autoindents
set autoindent              " Indent a new line the same amount as the line just typed
set cc=120                  " Set a vertical border for good coding style (in nb of chars)
syntax on                   " Enable syntax highlighting
set cursorline              " Highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim

" use fzf (installed via homebrew on Apple silicon)
" Using vim-plug instead
" set rtp+=/opt/homebrew/opt/fzf 

" System clipboard
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

""""""""""""""""""""""""""""""""
" vim-plug plugin manager
""""""""""""""""""""""""""""""""
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()

""""""""""""""""""""""""""""""""
" Color theme
""""""""""""""""""""""""""""""""
silent! colorscheme catppuccin

""""""""""""""""""""""""""""""""
" Keybinding configurations
""""""""""""""""""""""""""""""""
" nore = no recursion
" - inoremap: maps the key in *insert* mode
" - nnoremap: maps the key in *normal* mode
" - vnoremap: maps the key in *visual* mode
" - A: alt/opt key
" - C: ctrl/cmd key
" - S: shift key
""""""""""""""""""""""""""""""""

" move line or visually selected block - alt+j/k
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
" copies filepath to clipboard by pressing yf (yank filepath)
nnoremap <silent> yf :let @+=expand('%:p')<CR>
" copies pwd to clipboard: command yd (yank directory)
nnoremap <silent> yd :let @+=expand('%:p:h')<CR>
" Replaces U for redo
nnoremap U <C-R>
" Remap comma as leader key
" let mapleader=","
" Press pp to paste last yank (saved on register 0)
"nnoremap <leader>pp "0p
" Save cut words into a different register to prevent overwriting yanks 
nnoremap d "_d
" Press i to enter insert mode, and ii to exit insert mode.
inoremap ii <Esc>
