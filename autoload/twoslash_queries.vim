function! s:setup_var(name, default) abort
    let g:[a:name] = get(g:, a:name, a:default)
endfunction

let s:base_config = {
    \ '*': {
        \ 'function': 'twoslash_queries#invoke_ycm_at',
        \ 'ycm_cmds': [ 'GetHover', 'GetType', 'GetDoc' ],
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

function! twoslash_queries#invoke_at(cursor, fun, ...) abort
    let l:curpos = getcurpos()
    let l:winpos = winsaveview()

    try
        if a:cursor != []
            call cursor(a:cursor)
        endif
        return call(a:fun, a:000)
    finally
        call setpos('.', l:curpos)
        call winrestview(l:winpos)
    endtry
endfunction

function! s:invoke_ycm() abort
    let l:commands = twoslash_queries#get_opt('ycm_cmds')
    for l:cmd in l:commands
        let l:result = youcompleteme#GetCommandResponse(l:cmd)
        if l:result != ''
            return l:result
        endif
    endfor
    return ''
endfunction

function! twoslash_queries#invoke_ycm_at(cursor) abort
    return twoslash_queries#invoke_at(a:cursor, 's:invoke_ycm')
endfunction

function! s:update() abort
    " TODO: Is it possible to do this without moving cursor, to enable async?
    " `youcompleteme#GetCommandResponse` could be patched to take cursor position,
    " but `search()` does not seem to be able to start at different line.
    "
    " You could use `filter(range(0, line('$')), 'getline(v:val, l:pattern)>=0')`,
    " but on 10KLOC files it is an order of magnitude slower
    " (RPi4B: 90ms vs 8s, filter with lambda is 150ms, handwritten loop is 220ms).
    call cursor(1, 1)
    let l:pattern = '\v^\s*' .. twoslash_queries#get_opt('comment') .. '\s*\^\?'
    let l:fun = twoslash_queries#get_opt('function')
    while search(l:pattern, 'W') > 0
        if stridx(getline('.'), '^?:') >= 0
            normal f:D0
        endif

        " +1 to convert from 0-indexed Vimscript to 1-indexed Vim cursor
        let l:col = stridx(getline('.'), '^') + 1
        let l:prev_line = line('.') - 1
        let l:result = function(l:fun)([ l:prev_line, l:col ])
        if l:result != ''
            execute 'normal A:  ' .. result
        endif
    endwhile
endfunction

function! twoslash_queries#update() abort
    call twoslash_queries#invoke_at([], 's:update')
endfunction

function! twoslash_queries#update_on_save() abort
    if twoslash_queries#get_opt('onsave')
        call twoslash_queries#update()
    endif
endfunction

