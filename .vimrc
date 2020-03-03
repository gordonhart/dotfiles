
" small vimrc

" colored syntax with non-standard color scheme
syntax on
color desert
highlight LineNr ctermfg=DarkGrey

" tabs as four spaces (personal preference)
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set nu
set nowrap

" save with double backslash \\
nmap \\ :w<CR>

" capital D in command mode to delete to previous line end
nmap D ^d0i<Bs> <esc>

" capital B to return to previous buffer
nmap B :b#<CR>

" color column 80, 100
set colorcolumn=80,100
highlight ColorColumn ctermbg=234

" automatically fold doc comments in Rust
autocmd FileType rust setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\s*///'
