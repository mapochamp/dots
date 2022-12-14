let g:vimtex_compiler_latexmk = {
    \ 'backend' : 'process',
    \ 'background' : 0,
    \ 'continuous' : 0,
    \ 'callback' : 0,
    \ 'options' : [
    \   '-pdf',
    \   '-shell-escape',
    \   '-xelatex',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode'
    \ ]
    \ }

let g:vimtex_latexmk_continuous = 0
let g:vimtex_latexmk_background = 0
let g:vimtex_motion_enabled = 0
let g:vimtex_index_show_help = 0
let g:vimtex_index_split_width = 40
" This breaks minted and some include{} situations... damn
"let g:vimtex_latexmk_build_dir = './output/'

" Integrate with YouCompleteMe for \cite{} and \ref{} autocompletion
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = [
    \ 're!\\[A-Za-z]*(ref|cite)[A-Za-z]*([^]]*])?{([^}]*, ?)*'
    \ ]

" Override tagbar with vimtex-toc-toggle
autocmd! FileType tex map T <plug>(vimtex-toc-toggle)
