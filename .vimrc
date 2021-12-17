call plug#begin('~/.vim/plugged')
  Plug 'bkad/CamelCaseMotion'
  Plug 'inkch/vim-fish'
  Plug 'dracula/vim', { 'as': 'dracula' }
  Plug 'editorconfig/editorconfig-vim'
  Plug 'itchyny/lightline.vim'
  Plug 'jparise/vim-graphql'
  Plug 'junegunn/fzf.vim'
  Plug 'leafgarland/typescript-vim'
  Plug 'lervag/vimtex'
  Plug 'mxw/vim-jsx'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'pangloss/vim-javascript'
  Plug 'peitalin/vim-jsx-typescript'
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

""" NERDTree

let NERDTreeMinimalUI=1

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif


""" CoC
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ ]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>af  <Plug>(coc-fix-current)


""" JS
let g:jsx_ext_required = 0
if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  " https://github.com/neoclide/coc-eslint/pull/118#issuecomment-973640987
  let g:coc_global_extensions += ['coc-eslint8']
endif

""" LATEX
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'mupdf'
"let g:vimtex_compiler_latexmk = {'callback' : 0}
let NERDTreeRespectWildIgnore = 1
if has('clientserver') && empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
