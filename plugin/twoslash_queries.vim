" TODO: TwoslashQueriesPointHere
" TODO: make comments less strict?
" TODO: support other file types
" TODO: display strategies
" TODO: async
" TODO: multiple pointers per line
" const z = x + y
" //    ^?  |   |
" //        ^?  |
" //            ^?
" TODO: targeted and same-line pointers:
" const z = x + y  // <(x)?

command! TwoslashQueriesUpdate call twoslash_queries#update()
nnoremap <silent> <Plug>(TwoslashQueriesUpdate) :TwoslashQueriesUpdate<CR>

