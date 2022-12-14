" Close the GDB buffer upon termination
let g:ConqueTerm_CloseOnEnd = 1

" Don't show annoying startup warnings
let g:ConqueTerm_StartMessages = 0

function ConqueTermStartupActions(term)
    " shrink window height to 10 rows
    resize 10
endfunction

call conque_term#register_function('after_startup', 'ConqueTermStartupActions')
