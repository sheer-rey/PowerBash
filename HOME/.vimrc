" enable pathogen plugin manager
execute pathogen#infect()

" set colorscheme
colorscheme Monokai_Gavin

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
set langmenu=none               " set vim menu language to english(default)
set expandtab                   " use the several spaces while press <Tab> key in insert mode
set tabstop=4                   " set tab size to 4 spaces
set shiftwidth=4                " set indent size to 4 spaces
set showmatch                   " turn on matching brackets jumping
set wildmenu                    " turn on vim enhanced built-in command-line completion
set noswapfile                  " turn off the swap file
set completeopt=menuone,preview " set auto-complete properties in insert mode
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
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
""" key map for toggle NERDTree window
nnoremap <silent> <leader>n :NERDTreeToggle<CR> 
""" set git status indicator for NERDtree-git-plugin
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \   'Modified'  :'✹',
    \   'Staged'    :'✚',
    \   'Untracked' :'✭',
    \   'Renamed'   :'➜',
    \   'Unmerged'  :'═',
    \   'Deleted'   :'✖',
    \   'Dirty'     :'✗',
    \   'Ignored'   :'☒',
    \   'Clean'     :'✔︎',
    \   'Unknown'   :'?',
    \}

"" settings for rainbow plugin
""" enable rainbow plugin by default, set to 0, enable it via :RainbowToggle
let g:rainbow_active = 1        

"" settings for a.vim plugin
nmap <Leader>a :A<CR>

"" settings for lightline plugin
function GitBranch()
    return '⎇  ' . gitbranch#name()
endfunction
let g:lightline = {
    \   'colorscheme': 'wombat',
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
nnoremap <Leader>oy :call OscYank()<CR>










"高亮搜索关键词"
let g:ackhighlight = 1
"修改快速预览窗口高度为15
let g:ack_qhandler = "botright copen 15"

let curpwd = getcwd()

" ack搜索时不打开第一个搜索文件
map <Leader>fw :Ack! <Space>
" AckFile不打开第一个搜索文件
map <Leader>ff :AckFile!<Space>


" 使用TlistToggle查看文件函数列表。设置快捷键：<F12>
nnoremap  <Leader>m  :TlistToggle <CR> 
" 粘贴到系统剪切板
map <Leader>y "*y
"禁止自动改变当前Vim窗口的大小
let Tlist_Inc_Winwidth=0
"把方法列表放在屏幕的右侧
let Tlist_Use_Right_Window=1
"让当前不被编辑的文件的方法列表自动折叠起来
let Tlist_File_Fold_Auto_Close=1 
" let g:winManagerWindowLayout='FileExplorer'
" 定义快捷键 打开/关闭 winmanger
" nmap wm :WMToggle<cr>
" let g:winManagerWidth=20

" 取消补全内容以分割子窗口形式出现，只显示补全列表

"cs add $curpwd/cscope.out $curpwd/
let g:SuperTabRetainCompletionType=2
let g:SuperTabDefaultCompletionType="<C-X><C-O>"
set cscopequickfix=s-,c-,d-,i-,t-,e-



let cwd=""

"设置winmanager窗口宽度
"let g:winManagerWidth = 30 

" 重新打开文档时光标回到文档关闭前的位置
if has("autocmd")
 autocmd BufReadPost *
 \ if line("'\"") > 0 && line ("'\"") <= line("$") |
 \ exe "normal g'\"" |
\ endif
endif


autocmd InsertEnter * se cul    " 用浅色高亮当前行"

" vim-commentary style set 注释针对不同语言的注释方法
autocmd FileType cpp set commentstring=//\ %s
" 开启语义分析
syntax enable
syntax on

" 添加自动补全字典
au FileType cpp setlocal dict+=~/.vim/dict/cpp_keywords_list.txt


autocmd BufEnter * silent! lcd %:p:h
let OmniCpp_MayCompleteDot=1    "  打开  . 操作符
let OmniCpp_MayCompleteArrow=1  " 打开 -> 操作符
let OmniCpp_MayCompleteScope=1  " 打开 :: 操作符
let OmniCpp_NamespaceSearch=1   " 打开命名空间
let OmniCpp_GlobalScopeSearch=1  
let OmniCpp_DefaultNamespace=["std"]  
let OmniCpp_ShowPrototypeInAbbr=1  " 打开显示函数原型
let OmniCpp_SelectFirstItem = 2 " 自动弹出时自动跳至第一个

