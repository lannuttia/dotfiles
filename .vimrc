set showcmd
set autoindent
set confirm
set number
set shiftwidth=2
set tabstop=4
set expandtab

let g:ale_fixers = {
\  'python': [
\    'autopep8',
\  ],
\  'vim': [
\    'vint',
\  ],
\  'rust': [
\    'rustc',
\    'rls',
\  ],
\  'c': [
\    'gcc',
\  ],
\}
let g:ale_linters = {
\  'python': [
\    'pylsp',
\  ],
\  'rust': [
\    'rls',
\  ],
\  'c': [
\    'ccls',
\  ],
\}
let g:ale_completion_enabled=1
let g:ale_hover_to_floating_preview=1

let g:airline#extensions#tabline#enabled=1

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall

syntax on
colorscheme dracula

" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
