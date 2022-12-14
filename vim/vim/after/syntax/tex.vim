" after a little experimentation with the help of :scriptnames, it seems that
" /usr/share/vim/vim74/syntax/tex.vim fucking unsets syntax spell toplevel
" on my system.  Putting this here is the only fix.  Not even putting this in
" after/plaintex.vim worked!  (For test file :set filetype? gives plaintex)
syntax spell toplevel
set spell
