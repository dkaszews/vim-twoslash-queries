set rtp+=../
set rtp+=dependencies/YouCompleteMe/
source ../plugin/twoslash_queries.vim
source dependencies/YouCompleteMe/plugin/youcompleteme.vim

function RunTest(...) abort
    " YCM can take a second to load
    if !(exists(':YcmCompleter'))
        return timer_start(1000, 'RunTest')
    endif

    set filetype=typescript
    TwoslashQueriesUpdate
    write
    quit
endfunction

call RunTest()

