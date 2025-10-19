" ================================================================================================ "
" @file     ctagslabel.vim
" @brief    Detect ctags implementation (Universal vs Exuberant) and set GTAGSLABEL accordingly.
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

" Function: ctagslabel#detect_label
" Brief: Detect whether the installed 'ctags' is Exuberant or Universal.
" Returns: 'ctags-exuberant', 'ctags-universal', or empty string if undetectable.
function! ctagslabel#detect_label() abort
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

" Function: ctagslabel#get_gtags_label
" Brief: Get the GTAGSLABEL value based on detected ctags implementation.
" Returns: 'new-ctags' for Universal, 'ctags' for Exuberant, or 'default' if undetectable.
function! ctagslabel#get_gtags_label() abort
    let l:label = ctagslabel#detect_label()
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
