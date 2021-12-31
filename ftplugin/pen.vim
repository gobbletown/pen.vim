" Map <C-x><C-m> for our custom completion
inoremap <C-x><C-m> <C-r>=PenComplete()<CR>

" Make subsequent <C-m> presses after <C-x><C-m> go to the next entry (just like
" other <C-x>* mappings)
" inoremap <expr> <C-m> pumvisible() ?  "\<C-n>" : "\<C-m>"

" Complete function for addresses; we match the name & address
fun! PenComplete()
    " The data. In this example it's static, but you could read it from a file,
    " get it from a command, etc.
    let l:data = [
        \ ["Elmo the Elk", "daring@brave.com"],
        \ ["Eek the Cat", "doesnthurt@help.com"]
    \ ]

    " Locate the start of the word and store the text we want to match in l:base
    let l:line = getline('.')
    let l:start = col('.') - 1
    while l:start > 0 && l:line[l:start - 1] =~ '\a'
        let l:start -= 1
    endwhile
    let l:base = l:line[l:start : col('.')-1]

    " Record what matches − we pass this to complete() later
    let l:res = []

    " Find matches
    for m in l:data
        " Check if it matches what we're trying to complete; in this case we
        " want to match against the start of both the first and second list
        " entries (i.e. the name and email address)
        if l:m[0] !~? '^' . l:base && l:m[1] !~? '^' . l:base
            " Doesn't match
            continue
        endif

        " It matches! See :help complete() for the full docs on the key names
        " for this dict.
        call add(l:res, {
            \ 'icase': 1,
            \ 'word': l:m[0] . ' <' . l:m[1] . '>, ',
            \ 'abbr': l:m[0],
            \ 'menu': l:m[1],
            \ 'info': len(l:m) > 2 ? join(l:m[2:], "\n") : '',
        \ })
    endfor

    " Now call the complete() function
    call complete(l:start + 1, l:res)
    return ''
endfun

function! Prompt(fun, ...)
    let args = a:000
    let s = ""
    " skip the first of the variadic args because it's the input
    for arg in args[1:]
        let s = s . ' "' . arg . '"'
    endfor

    let cmd = a:fun . s
    " let s = system("penf -u " . cmd, @p)
    let @p = s

    " paste from p register
    exe "normal! gv\"pp"
endfunction

xnoremap Zt "py:silent! call Prompt("pf-transform-code/3", @p, "vim", input("transformation: "))<CR>
