" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif


call plug#begin()
  
  Plug 'tpope/vim-surround'
  
  Plug 'scrooloose/nerdtree'

  Plug 'scrooloose/syntastic'
  
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  
  Plug 'ctrlpvim/ctrlp.vim'

call plug#end()
 
set number
set rnu
let g:airline_theme='simple'
