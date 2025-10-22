" ================================================================================================ "
" @file     tagshelper.vim
" @brief    Helper functions for detecting ctags implementation and setting up cscope in Vim.
"
" @author   sheer.rey<sheer.rey@gmail.com>
" @date     10/18/2025
" @version  0.0.1
" ================================================================================================ "

" ================================================================================================ "
" private functions
" ================================================================================================ "

" Function: s:version_output
" Brief: Return the output (string) of the given command safely.
" Parameter: <cmd> may be a string (shell form) or a list (exec form).
" Returns: output string of <cmd>, or empty string on failure.
function! s:version_output(cmd) abort
    try
        " systemlist returns a List of lines; join into single string.
        let l:lines = systemlist(a:cmd)
        return join(l:lines, "\n")
    catch
        " If anything fails, return empty string.
        return ''
    endtry
endfunction

" ================================================================================================ "
" public functions
" ================================================================================================ "

" Function: tagshelper#detect_label
" Brief: Detect whether the installed 'ctags' is Exuberant or Universal.
" Returns: 'ctags-exuberant', 'ctags-universal', or empty string if undetectable.
function! tagshelper#detect_label() abort
    " Initialize label to empty
    let l:label = ''

    " Try common executable names and version output
    if executable('ctags')
        let l:out = s:version_output('ctags --version')

        " Decide by searching for known keywords (case-insensitive)
        if l:out =~? 'Universal'
            let l:label = 'ctags-universal' " universal-ctags -> new-ctags label in gtags.conf
        elseif l:out =~? 'Exuberant'
            let l:label = 'ctags-exuberant' " exuberant-ctags -> ctags label in gtags.conf
        endif
    endif

    return l:label
endfunction

" Function: tagshelper#get_gtags_label
" Brief: Get the GTAGSLABEL value based on detected ctags implementation.
" Returns: 'new-ctags' for Universal, 'ctags' for Exuberant, or 'default' if undetectable.
function! tagshelper#get_gtags_label() abort
    let l:label = tagshelper#detect_label()
    if !empty(l:label)
        if l:label ==# 'ctags-universal'
            return 'new-ctags'
        elseif l:label ==# 'ctags-exuberant'
            return 'ctags'
        endif
    else
        return 'default'
    endif
endfunction

" Function: tagshelper#setup_cscope
" Brief: Setup cscope database in Vim, preferring gtags-cscope if available.
"        Searches for 'GTAGS' or 'cscope.out' in the current directory and parents.
" Notes: Call this function after opening a project in Vim to enable cscope support.
"        If a cscope database is found, it is added to Vim's cscope connections.
"        If no database is found, a message is displayed.
function! tagshelper#setup_cscope() abort
    let l:prefer_gtags_cscope = 0
    let l:cscope_file = ''

    " Prefer gtags-cscope if available
    if executable('gtags-cscope')
        let l:cscope_file = findfile('GTAGS', '.;')
        if !empty(l:cscope_file)
            let l:prefer_gtags_cscope = 1
            set cscopeprg='gtags-cscope'
        endif
    endif

    " Fallback to standard cscope.out if gtags-cscope not preferred or not found
    if !l:prefer_gtags_cscope
        let l:cscope_file = findfile('cscope.out', '.;')
    endif
    
    " If cscope database file is not found, notify the user and exit
    if empty(l:cscope_file)
        echomsg '[cscope] Database not found'
        return
    endif

    " If a cscope database file is found, add it to Vim's cscope connections
    silent! cscope kill -1
    execute 'silent! cscope add ' . fnameescape(l:cscope_file) . ' ' . fnameescape(fnamemodify(l:cscope_file, ':h'))
    echomsg '[cscope] Setup database with ' . l:cscope_file
endfunction
