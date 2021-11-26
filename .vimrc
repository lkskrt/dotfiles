call plug#begin('~/.vim/plugged')
  Plug 'bkad/CamelCaseMotion'
  Plug 'dag/vim-fish'
  Plug 'dracula/vim', { 'as': 'dracula' }
  Plug 'editorconfig/editorconfig-vim'
  Plug 'itchyny/lightline.vim'
  Plug 'junegunn/fzf.vim'
  Plug 'leafgarland/typescript-vim'
  Plug 'lervag/vimtex'
  Plug 'mxw/vim-jsx'
  Plug 'pangloss/vim-javascript'
  Plug 'scrooloose/nerdtree'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
call plug#end()

set clipboard=unnamedplus " Copy and pasting from system clipboard
set number " Always show line numbers
set wildignore=*.aux,*.bbl,*.run.xml,*.synctex.gz,*.toc,*.xdv,*.log,*.bcf,*.blg,*.fdb_latexmk,*.fls,*.lof,*.out,
set noshowmode " Hide mode, because lightline already shows it
set laststatus=2 " Show lightline when there is only one screen
set ts=2 sts=2 sw=2 expandtab " Tab width 4, soft tab 2, shift width 2, use spaces
set wrap linebreak " Wrap lines, do not break words
set ignorecase smartcase incsearch " ignore case only when searching lowercase, search while typing
let g:tex_flavor = 'latex'
syntax on " Syntax highlighting
filetype plugin on
filetype indent on


let mapleader = ' '
let maplocalleader = ','
map <C-p> :Files<CR>
map <C-t> :NERDTreeToggle<CR>
nmap <leader>v :tabedit $MYVIMRC<CR>
nmap <leader>s :w<CR>
inoremap <C-@> <C-x><C-o>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

let g:camelcasemotion_key = '<localleader>'

" Source the vimrc file after saving it
if has('autocmd')
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Fix color problems when using alacritty: https://github.com/alacritty/alacritty/issues/2149#issuecomment-472602005
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
colorscheme dracula

let NERDTreeMinimalUI=1

" JS
let g:jsx_ext_required = 0


" LATEX
let g:vimtex_view_method = 'mupdf'
"let g:vimtex_compiler_latexmk = {'callback' : 0}
let NERDTreeRespectWildIgnore = 1
if has('clientserver') && empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
