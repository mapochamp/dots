" Vim currently only recognizes README.md as a Markdown file.  All other *.md
" files are treated as Modula-2 files.  This forces all *.md files to be
" treated as Markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" comment out markdown lines with [//]: # ( Comment )
" this is the best chances of being honored
autocmd Filetype markdown setlocal commentstring=[\/\/]:\ #\ (%s)
