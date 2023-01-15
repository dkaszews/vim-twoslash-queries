command! TwoslashQueriesUpdate call twoslash_queries#update()
nnoremap <silent> <Plug>(TwoslashQueriesUpdate) :TwoslashQueriesUpdate<CR>

augroup TwoslashQueries
    autocmd!
    autocmd BufWritePost * call twoslash_queries#update_on_save()
augroup END

