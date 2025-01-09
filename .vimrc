set nocompatible            " Disable compatibility with vi which can cause unexpected issues
filetype on                 " Enable type file detection. Vim will be able to try to detect the type of file in use
filetype plugin on          " Enable plugins and load plugin for the detected file type
filetype indent on          " Load an indent file for the detected file type.
set number                  " Show line numbers
set hlsearch                " Highlight search 
set incsearch               " Incremental search
set tabstop=4               " Number of columns occupied by a tab 
set softtabstop=4           " See multiple spaces as tabstops so <BS> does the right thing
set expandtab               " Converts tabs to white space
set shiftwidth=4            " Width for autoindents
set autoindent              " Indent a new line the same amount as the line just typed
set cc=100                  " Set a vertical border for good coding style (in nb of chars)
syntax on                   " Enable syntax highlighting
set cursorline              " Highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim

" System clipboard
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif


set rtp+=/opt/homebrew/opt/fzf  " use fzf"

