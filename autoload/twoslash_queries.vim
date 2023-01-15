function! s:setup_var(name, default) abort
    let g:[a:name] = get(g:, a:name, a:default)
endfunction

call s:setup_var('twoslash_queries#preferred_commands', [ 'GetType', 'GetHover' ])

" Cache commands to use, speeds up execution slightly
function! twoslash_queries#get_ycm_commands() abort
    " Cannot use '#' in non-global variables
    if !exists('b:twoslash_queries_preferred_defined_cmds')
        if !exists('*youcompleteme#GetDefinedSubcommands')
            echoerr 'YCM not available'
            let b:twoslash_queries_preferred_defined_cmds = []
            return []
        endif

        let l:defined = youcompleteme#GetDefinedSubcommands()
        if l:defined == []
            return []
        endif

        let b:twoslash_queries_preferred_defined_cmds
            \ = filter(g:twoslash_queries#preferred_commands,
                       \ { i, v -> index(l:defined, v) >= 0 })
    endif
    return b:twoslash_queries_preferred_defined_cmds
endfunction

" Invokes preferred command(s) at current cursor position
function! twoslash_queries#invoke_ycm_command() abort
    let l:preferred = twoslash_queries#get_ycm_commands()
    if l:preferred == []
        echoerr 'None of the preferred commands are defined'
        return ''
    endif

    for l:cmd in l:preferred
        let l:result = youcompleteme#GetCommandResponse(l:cmd)
        if l:result != ''
            return l:result
        endif
    endfor
    return ''
endfunction

function! s:invoke_with_cursor_restore(fun, ...) abort
    let l:curpos = getcurpos()
    let l:winpos = winsaveview()

    try
        return call(a:fun, a:000)
    finally
        call setpos('.', l:curpos)
        call winrestview(l:winpos)
    endtry
endfunction

function! s:update() abort
    " TODO: Is it possible to do this without moving cursor, to enable async?
    " Line editing can be done using `get/setline()`
    " and `youcompleteme#GetCommandResponse` could be patched to take cursor position,
    " but `search()` does not seem to be able to start at different line.
    call cursor(1, 1)
    while search('\v^ *// *\^\?', 'W') > 0
        if stridx(getline('.'), '^?:') >= 0
            normal f:D0
        endif
        normal f^k
        let l:result = twoslash_queries#invoke_ycm_command()
        normal j
        if l:result != ''
            execute 'normal A:  ' .. result
        endif
    endwhile
endfunction

function! twoslash_queries#update() abort
    call s:invoke_with_cursor_restore('s:update')
endfunction

