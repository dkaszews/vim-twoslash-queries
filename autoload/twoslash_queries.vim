function! s:setup_var(name, default) abort
    let g:[a:name] = get(g:, a:name, a:default)
endfunction

let s:base_config = {
    \ '*': {
        \ 'commands': [ 'GetHover', 'GetType', 'GetDoc' ],
        \ 'comment': '//',
        \ 'onsave': 0,
    \ },
    \ 'python': {
        \ 'comment': '#',
    \ },
\}

" Merge default and user configs, ensure fallback '*' has all values
call s:setup_var('twoslash_queries_config', {})
let g:twoslash_queries_config = extend(deepcopy(s:base_config), g:twoslash_queries_config)
call extend(g:twoslash_queries_config['*'], s:base_config['*'])

function! twoslash_queries#get_opt(name) abort
    if exists('b:twoslash_queries_config')
        \ && has_key(b:twoslash_queries_config, a:name)
        return b:twoslash_queries_config[a:name]
    elseif has_key(g:twoslash_queries_config, &filetype)
        \ && has_key(g:twoslash_queries_config[&filetype], a:name)
        return g:twoslash_queries_config[&filetype][a:name]
    endif
    return g:twoslash_queries_config['*'][a:name]
endfunction

" Invokes preferred command(s) at current cursor position
function! twoslash_queries#invoke_ycm_command() abort
    let l:commands = twoslash_queries#get_opt('commands')
    for l:cmd in l:commands
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
    let l:pattern = '\v^\s*' .. twoslash_queries#get_opt('comment') .. '\s*\^\?'
    while search(l:pattern, 'W') > 0
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

function! twoslash_queries#update_on_save() abort
    if twoslash_queries#get_opt('onsave')
        call twoslash_queries#update()
    endif
endfunction

