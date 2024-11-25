" enable pathogen plugin manager
execute pathogen#infect()

" enable syntax highlighting and keep most of current color settings
syntax enable

" set colorscheme
colorscheme dracula
highlight Normal ctermfg=255 ctermbg=235
highlight ColorColumn term=reverse ctermbg=238
highlight Comment cterm=italic ctermfg=244

" turn on filetype detect and enable loading relevant plugin and indent file
filetype on
filetype plugin on
filetype indent on

" vim built-in settings
set nocompatible                " set vim running in nocompatible mode
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " turn on autoindent
set cindent                     " turn on autoindent on for C/C++
set cinoptions=g-1              " set cindent options: indent for multi-line statements
set nobackup                    " turn off the backup file
set number                      " turn on the line number
set history=50                  " set command line history with 50 lines
set ruler                       " show the line and column number of the cursor position
set showcmd	                    " display incomplete commands at bottom right of the window
set hlsearch                    " turn on searching highlight
set incsearch                   " turn on incremental searching
set nowrap                      " turn off the line wrap while exceed window width
set langmenu=none               " set vim menu language to default
set expandtab                   " use the several spaces while press <Tab> key in insert mode
set tabstop=4                   " set tab size to 4 spaces
set shiftwidth=4                " set indent size to 4 spaces
set showmatch                   " turn on matching brackets jumping
set wildmenu                    " turn on vim enhanced built-in command-line completion
set noswapfile                  " turn off the swap file
set completeopt=menu,menuone,preview,noselect   " set auto-complete properties in insert mode
set shortmess+=c                " don't show 'ins-completion-menu' messages
set nofoldenable                " not fold any text while file was opened
set ignorecase                  " set case-insensitive in search patterns
set smartcase                   " turn on case-sensitive while upper case exist in search patterns
set mouse=nv                    " enable mouse support in normal and visual mode
set tags=tags;/                 " specify tags searching path upward to root(/)
set shortmess=atToO             " set short message types
set modeline                    " enable vim modeline
set modelines=5                 " set the count of valid vim modelines
set colorcolumn=100             " highlighting 100th coloum for auxiliary
set laststatus=2                " set windows always have the status line
set noshowmode                  " do not show Insert/Replace/Visual mode on the last line
set cursorline                  " highlight the text line of the cursor
set csqf=s-,c-,d-,i-,t-,e-      " show cscope results in quickfix window (cscopequickfix)

" vim built-in settings for character encoding
set encoding=utf-8              " set encoding for vim internal use
setglobal fileencoding=utf-8    " set global encoding for new file
set fileencodings=ucs-bom,utf-8,default,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" define new <Leader> key and key mappings
let mapleader = ";"
"" jumping to the window left
nnoremap <leader>h <C-W><C-H>
"" jumping to the window right
nnoremap <leader>l <C-W><C-L>
"" jumping to the window above
nnoremap <leader>k <C-W><C-K>
"" jumping to the window below
nnoremap <leader>j <C-W><C-J>
"" split current window and explore current file's directory
nmap <Leader>s :Sexplore<CR>
"" vertical split current window and explore current file's directory
nmap <Leader>v :Vexplore<CR>

" settings for plugins
"" settings for NERDTree plugin and sub-plugins
let NERDTreeWinPos = "left"     " set NERDTree window position to left
let NERDTreeShowHidden = 1      " set NERDTree window show hidden files
""" close the tab if NERDTree is the only window remaining in it.
if has("autocmd")
    autocmd BufEnter *
    \   if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
endif
""" key map for toggle NERDTree window
nnoremap <leader>n :NERDTreeToggle<CR> 
""" set git status indicator for NERDtree-git-plugin
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \   'Modified'  :'~',
    \   'Staged'    :'+',
    \   'Untracked' :'«',
    \   'Renamed'   :'→',
    \   'Unmerged'  :'!',
    \   'Deleted'   :'x',
    \   'Dirty'     :'*',
    \   'Ignored'   :'…',
    \   'Clean'     :'✓',
    \   'Unknown'   :'?',
    \}

"" settings for rainbow plugin
""" enable rainbow plugin by default, set to 0, enable it via :RainbowToggle
let g:rainbow_active = 1        

"" settings for a.vim plugin
nmap <Leader>a :A<CR>

"" settings for lightline plugin
function GitBranch()
    let l:branch = gitbranch#name()
    if empty(l:branch)
        return ''
    endif
    return '⎇  ' . l:branch
endfunction
let g:lightline = {
    \   'colorscheme': 'dracula',
    \   'active': {
    \       'left': [
    \           [ 'mode', 'paste' ],
    \           [ 'gitbranch', 'filename', 'readonly', 'modified' ],
    \       ],
    \       'right': [
    \           [ 'lineinfo' ],
    \           [ 'percent' ],
    \           [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ],
    \       ],
    \   },
    \   'component': {
    \       'charvaluehex': '0x%B',
    \   },
    \   'component_function': {
    \       'gitbranch': 'GitBranch',
    \   },
    \}

"" settings for taglist.vim plugin
let Tlist_Inc_Winwidth = 0              " disable auto increase window width to accommodate taglist
let Tlist_Use_Right_Window = 1          " place the taglist window on the right side
let Tlist_File_Fold_Auto_Close = 1      " auto close the tags tree for inactive files
let Tlist_GainFocus_On_ToggleOpen = 1   " move the cursor to the taglist window when it opened
let Tlist_Exit_OnlyWindow = 1           " exit vim if the taglist is the only window
""" key map for toggle taglist window
nnoremap <Leader>m :TlistToggle<CR> 

"" settings for ack.vim plugin
let g:ackprg              = "ag --vimgrep"      " use 'ag' for searching instead of ack
let g:ack_apply_qmappings = 1                   " enable internal key mappings in quickfix window
let g:ackhighlight        = 1                   " highlight searched term in quickview window
let g:ack_qhandler        = "botright copen 15" " open quickview window with 15 lines height

"" settings for OmniCppComplete plugin
set omnifunc=omni#cpp#complete
let OmniCpp_MayCompleteDot      = 1 " enable completion after .
let OmniCpp_MayCompleteArrow    = 1 " enable completion after ->
let OmniCpp_MayCompleteScope    = 1 " enable completion after ::
let OmniCpp_NamespaceSearch     = 1 " enable searching symbols in namespace scope
let OmniCpp_GlobalScopeSearch   = 1 " enable searching symbols in global scope
let OmniCpp_DefaultNamespace    = ["std"]   " set default namespace to 'std'
let OmniCpp_ShowPrototypeInAbbr = 1 " show function prototypes in completion list
let OmniCpp_SelectFirstItem     = 2 " automatically select the first result in completion list

"" settings for vim-auto-popmenu plugin
let g:apc_enable_ft = {'*':1}       " enable this plugin for all filetypes
let g:apc_cr_confirm = 1            " use <CR> to confirm the selection

" register auto commands
if has("autocmd")
    "" let cursor return to the position before the file closed when it's reopened
    autocmd BufReadPost *
    \   if line("'\"") > 0 && line("$") > 1 && line ("'\"") <= line("$") |
    \       execute "normal! g'\"" |
    \   endif
    "" set local current directory to the parent directory of current buffer file
    autocmd BufEnter * silent! lcd %:p:h
    "" set commentstring to '// ' for c++ files
    autocmd FileType cpp set commentstring=//\ %s
    "" add keywords list to dictionary of current buffer for c++ files
    autocmd FileType cpp execute 'setlocal dictionary+=' .
    \   expand(fnamemodify($MYVIMRC, ':h') . '/.vim/dictionary/cpp_keywords_list.txt')
endif

" support yank to remote terminal via osc52 escape sequence
function OscYank()
    let text = substitute(getreg('"'), '\r\|\r\n', '\n', 'g')
    if empty(text)
        return
    endif
    let osc52_seq = system('echo ' . shellescape(text) . ' | osc_yank')
    if filewritable('/dev/fd/2') == 1
        call writefile([osc52_seq], '/dev/fd/2', 'b')
    endif
endfunction
nnoremap <Leader>y :call OscYank()<CR>

