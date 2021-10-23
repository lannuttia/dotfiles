set showcmd
set autoindent
set confirm
set number
set shiftwidth=2
set tabstop=4
set expandtab

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall

syntax on
colorscheme darkslategray

" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
