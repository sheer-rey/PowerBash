" ================================================================================================ "
" @file     githelper.vim
" @brief    Helpers for Git integration in Vim.
"
" @author   sheer.rey<sheer.rey@gmail.com>
" @date     10/19/2025
" @version  0.0.1
" ================================================================================================ "

" ================================================================================================ "
" public functions
" ================================================================================================ "

" Function: githelper#get_branch_name
" Brief: Get the current Git branch name, prefixed with a branch symbol.
" Returns: A string like '⎇  branch_name' or an empty string if not in a Git repo.
function githelper#get_branch_name() abort
    let l:branch = gitbranch#name()
    if empty(l:branch)
        return ''
    endif
    return '⎇  ' . l:branch
endfunction
