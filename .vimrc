filetype plugin indent on     " required

set number                      " Show line numbers
set ruler                       " Show the cursor position all the time
set backspace=indent,eol,start  " Makes backspace key more powerful.
set showcmd                     " Show me what I'm typing
set showmode                    " Show current mode.
set autoindent
set complete-=i
set showmatch
set smarttab
set et
set tabstop=2
set shiftwidth=2
set expandtab

set noswapfile                  " Don't use swapfile
set nobackup			" Don't create annoying backup files
set nowritebackup

set encoding=utf-8              " Set default encoding to UTF-8

set autoread                    " Automatically reread changed files without asking me anything

syntax enable
if has('gui_running')
  " fix js regex syntax
  set regexpengine=1
  syntax enable
endif

let mapleader = " "

noremap <Leader>y "+y
noremap <Leader>P "+P
noremap <Leader>p "+p
