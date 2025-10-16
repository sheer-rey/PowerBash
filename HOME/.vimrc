" ================================================================================================ "
" @file     .vimrc
" @brief    Personal defined vim configuration file for using it powerful.
"
" @author   sheer.rey<sheer.rey@gmail.com>
" @date     03/07/2025
" @version  0.0.1
" ================================================================================================ "

" ================================================================================================ "
" enable pathogen plugin manager
" ================================================================================================ "
execute pathogen#infect()

" ================================================================================================ "
" enable syntax highlighting and keep most of current color settings
" ================================================================================================ "
syntax enable

" ================================================================================================ "
" set colorscheme
" ================================================================================================ "
"" disable fetures of dracula colorscheme if terminal not support
if empty(system('tput sitm 2>/dev/null')) | let g:dracula_italic = 0 | endif
if empty(system('tput smxx 2>/dev/null')) | let g:dracula_strikethrough = 0 | endif
"" set colorscheme to dracula
colorscheme dracula
"" re-define some new highlight rule
highlight Normal ctermfg=255 ctermbg=235
highlight Comment ctermfg=244 ctermbg=235
highlight ColorColumn ctermbg=238

" ================================================================================================ "
" turn on filetype detect and enable loading relevant plugin and indent file
" ================================================================================================ "
filetype on
filetype plugin on
filetype indent on

" ================================================================================================ "
" vim built-in settings
" ================================================================================================ "
set nocompatible                " set vim running in nocompatible mode
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " turn on autoindent
set cindent                     " turn on autoindent on for C/C++
set cinoptions=g-1              " set cindent options: indent for multi-line statements
set nobackup                    " turn off the backup file
set number                      " turn on the line number
set history=50                  " set command line history with 50 lines
set ruler                       " show the line and column number of the cursor position
set showcmd                     " display incomplete commands at bottom right of the window
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
set shortmess+=c                " don't show 'ins-completion-menu' messages
set nofoldenable                " not fold any text while file was opened
set ignorecase                  " set case-insensitive in search patterns
set smartcase                   " turn on case-sensitive while upper case exist in search patterns
set mouse=nv                    " enable mouse support in normal and visual mode
set tags=tags;/                 " specify tags searching path upward to root(/)
set shortmess=atToO             " set short message types
set modeline                    " enable vim modeline
set modelines=5                 " set the count of valid vim modelines
set textwidth=100               " set maximum textwidth for break lines automatically
set formatoptions+=t            " set automatically wrap text using textwidth
set colorcolumn=100             " highlighting 100th coloum for auxiliary
set laststatus=2                " set windows always have the status line
set noshowmode                  " do not show Insert/Replace/Visual mode on the last line
set cursorline                  " highlight the text line of the cursor
set csqf=s-,c-,d-,i-,t-,e-      " show cscope results in quickfix window (cscopequickfix)
set cscopetag                   " set ctrl+] command use cscope database additionally
set cscopetagorder=1            " set ctrl+] command use ctags prior to cscope database
set list                        " enable list mode
set updatetime=500              " set vim update time to 500ms
set signcolumn=auto             " set signcolumn draw mode to auto
"" set characters to show in list mode
set listchars=tab:▸-,trail:•,precedes:«,extends:»,eol:↲,nbsp:␣
"" set auto-complete properties in insert mode
if has('patch-7.4.775')
    " 'noselect' feture of completeopt introduced in vim patch 7.4.775
    set completeopt=menu,menuone,preview,noselect
else
    set completeopt=menu,menuone,preview
endif
"" vim built-in settings for character encoding
set encoding=utf-8              " set encoding for vim internal use
setglobal fileencoding=utf-8    " set global encoding for new file
set fileencodings=ucs-bom,utf-8,default,cp936,gb18030,big5,euc-jp,euc-kr,latin1

" ================================================================================================ "
" define new <Leader> key and key mappings
" ================================================================================================ "
let mapleader = ";"
"" jump to the window left
nnoremap <leader>h <C-W><C-H>
"" jumpng to the window right
nnoremap <leader>l <C-W><C-L>
"" jumpng to the window above
nnoremap <leader>k <C-W><C-K>
"" jumpng to the window below
nnoremap <leader>j <C-W><C-J>
"" split current window and explore current file's directory
nmap <Leader>s :Sexplore<CR>
"" vertical split current window and explore current file's directory
nmap <Leader>v :Vexplore<CR>
"" open quickfix window
nmap <Leader>co :copen<CR>
"" close quickfix window
nmap <Leader>cc :cclose<CR>
"" jump to next result of quickfix window
nmap <Leader>cn :cnext<CR>
"" jump to previous result of quickfix window
nmap <Leader>cp :cprev<CR>
"" show result list in quickfix window
nmap <Leader>cl :clist<CR>

" ================================================================================================ "
" settings for plugins
" ================================================================================================ "
"" settings for a.vim plugin
nmap <Leader>a :A<CR>

"" settings for ack.vim plugin
let g:ack_apply_qmappings = 1                   " enable internal key mappings in quickfix window
let g:ackhighlight        = 1                   " highlight searched term in quickview window
let g:ack_qhandler        = "botright copen 15" " open quickview window with 15 lines height
if executable('ag')
    let g:ackprg = "ag --vimgrep"               " use 'ag' for searching instead of ack if avaliable
endif

"" settings for indentline plugin
""" for compatible with indentline, vim 7.3 and above required
if v:version < 703 | let g:indentLine_enabled = 0 | endif

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
"""" for compatible with NERDTree-git-plugin, vim 8.1 and above required
if v:version < 801 | let g:NERDTreeGitStatusEnable = 0 | endif

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

"" settings for rainbow plugin
""" enable rainbow plugin by default, set to 0, enable it via :RainbowToggle
let g:rainbow_active = 1

"" settings for taglist.vim plugin
let Tlist_Inc_Winwidth = 0              " disable auto increase window width to accommodate taglist
let Tlist_Use_Right_Window = 1          " place the taglist window on the right side
let Tlist_File_Fold_Auto_Close = 1      " auto close the tags tree for inactive files
let Tlist_GainFocus_On_ToggleOpen = 1   " move the cursor to the taglist window when it opened
let Tlist_Exit_OnlyWindow = 1           " exit vim if the taglist is the only window
""" key map for toggle taglist window
nnoremap <Leader>m :TlistToggle<CR>

"" settings for vim-auto-popmenu plugin
let g:apc_enable_ft = {'*':1}       " enable this plugin for all filetypes
let g:apc_cr_confirm = 1            " use <CR> to confirm the selection
if !has('patch-7.4.775')
    " disable plugin's auto popup feture while vim do not have 'noselect' feture of completeopt
    " there's also another way to trigger completion popup window by using <TAB> or <C-n> keys
    let g:apc_enable_auto_pop = 0
endif

"" settings for vim-cppman plugin
if has("autocmd")
    autocmd FileType c,cpp setlocal keywordprg=:Cppman
endif

" ================================================================================================ "
" support load cscope databse while it exists
" ================================================================================================ "
function SetupCscope()
    if filereadable("cscope.out")
        silent! cscope kill -1
        silent! cscope add cscope.out
    endif
endfunction
command! CscopeReload call SetupCscope()

" ================================================================================================ "
" register auto commands
" ================================================================================================ "
if has("autocmd")
    "" autoload cscope database while it exists
    autocmd VimEnter * call SetupCscope()
    "" let cursor return to the position before the file closed when it's reopened
    autocmd BufReadPost *
    \   if line("'\"") > 0 && line("$") > 1 && line ("'\"") <= line("$") |
    \       execute "normal! g'\"" |
    \   endif
    "" set commentstring to '// ' for c/c++ files
    autocmd FileType c,cpp setlocal commentstring=//\ %s
    "" set keywordprg to Cppman for c/c++ files while vim version is 8.1 or above
    if v:version >= 801
        autocmd FileType c setlocal keywordprg=:Cppman!
        autocmd FileType cpp setlocal keywordprg=:Cppman
    endif
    "" do not expand tab to spaces while filetype is Makefile
    autocmd FileType Makefile setlocal noexpandtab
endif

" ================================================================================================ "
" support yank to remote terminal via osc52 escape sequence
" ================================================================================================ "
function OscYank()
    let text = substitute(getreg('"'), '\r\|\r\n', '\n', 'g')
    if empty(text)
        return
    endif
    let osc52_seq = system('echo '
                    \   . substitute(shellescape(text), '\\\n', '\n', 'g')
                    \   . ' | osc_yank')
    if filewritable('/dev/fd/2') == 1
        call writefile([osc52_seq], '/dev/fd/2', 'b')
    endif
endfunction
nnoremap <Leader>y :call OscYank()<CR>

