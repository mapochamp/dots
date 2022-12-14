" Vim color file
" Maintainer:   James A. Shackleford (shack at linux dot com)
" Last Change:  July 23rd, 2015
"
" easymoney.vim - a modified version of slate.vim that works on xterms with
" 88 or 256 colors. The algorithm for approximating the GUI colors with the
" xterm palette is from desert256.vim by Henry So Jr.


set background=dark

if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let g:colors_name = "easymoney"

if !has("gui_running") && &t_Co != 88 && &t_Co != 256
    finish
endif


" ======== START FUNCTIONS ================================================

" returns an approximate grey index for the given grey level
fun <SID>grey_number(x)
    if &t_Co == 88
        if a:x < 23
            return 0
        elseif a:x < 69
            return 1
        elseif a:x < 103
            return 2
        elseif a:x < 127
            return 3
        elseif a:x < 150
            return 4
        elseif a:x < 173
            return 5
        elseif a:x < 196
            return 6
        elseif a:x < 219
            return 7
        elseif a:x < 243
            return 8
        else
            return 9
        endif
    else
        if a:x < 14
            return 0
        else
            let l:n = (a:x - 8) / 10
            let l:m = (a:x - 8) % 10
            if l:m < 5
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfun

" returns the actual grey level represented by the grey index
fun <SID>grey_level(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 46
        elseif a:n == 2
            return 92
        elseif a:n == 3
            return 115
        elseif a:n == 4
            return 139
        elseif a:n == 5
            return 162
        elseif a:n == 6
            return 185
        elseif a:n == 7
            return 208
        elseif a:n == 8
            return 231
        else
            return 255
        endif
    else
        if a:n == 0
            return 0
        else
            return 8 + (a:n * 10)
        endif
    endif
endfun

" returns the palette index for the given grey index
fun <SID>grey_color(n)
    if &t_Co == 88
        if a:n == 0
            return 16
        elseif a:n == 9
            return 79
        else
            return 79 + a:n
        endif
    else
        if a:n == 0
            return 16
        elseif a:n == 25
            return 231
        else
            return 231 + a:n
        endif
    endif
endfun

" returns an approximate color index for the given color level
fun <SID>rgb_number(x)
    if &t_Co == 88
        if a:x < 69
            return 0
        elseif a:x < 172
            return 1
        elseif a:x < 230
            return 2
        else
            return 3
        endif
    else
        if a:x < 75
            return 0
        else
            let l:n = (a:x - 55) / 40
            let l:m = (a:x - 55) % 40
            if l:m < 20
                return l:n
            else
                return l:n + 1
            endif
        endif
    endif
endfun

" returns the actual color level for the given color index
fun <SID>rgb_level(n)
    if &t_Co == 88
        if a:n == 0
            return 0
        elseif a:n == 1
            return 139
        elseif a:n == 2
            return 205
        else
            return 255
        endif
    else
        if a:n == 0
            return 0
        else
            return 55 + (a:n * 40)
        endif
    endif
endfun

" returns the palette index for the given R/G/B color indices
fun <SID>rgb_color(x, y, z)
    if &t_Co == 88
        return 16 + (a:x * 16) + (a:y * 4) + a:z
    else
        return 16 + (a:x * 36) + (a:y * 6) + a:z
    endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun <SID>color(r, g, b)
    " get the closest grey
    let l:gx = <SID>grey_number(a:r)
    let l:gy = <SID>grey_number(a:g)
    let l:gz = <SID>grey_number(a:b)

    " get the closest color
    let l:x = <SID>rgb_number(a:r)
    let l:y = <SID>rgb_number(a:g)
    let l:z = <SID>rgb_number(a:b)

    if l:gx == l:gy && l:gy == l:gz
        " there are two possibilities
        let l:dgr = <SID>grey_level(l:gx) - a:r
        let l:dgg = <SID>grey_level(l:gy) - a:g
        let l:dgb = <SID>grey_level(l:gz) - a:b
        let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
        let l:dr = <SID>rgb_level(l:gx) - a:r
        let l:dg = <SID>rgb_level(l:gy) - a:g
        let l:db = <SID>rgb_level(l:gz) - a:b
        let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
        if l:dgrey < l:drgb
            " use the grey
            return <SID>grey_color(l:gx)
        else
            " use the color
            return <SID>rgb_color(l:x, l:y, l:z)
        endif
    else
        " only one possibility
        return <SID>rgb_color(l:x, l:y, l:z)
    endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun <SID>rgb(rgb)
    let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
    let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
    let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
    return <SID>color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun <SID>X(group, fg, bg, attr)
    if a:fg != ""
        exec "hi ".a:group." guifg=#".a:fg." ctermfg=".<SID>rgb(a:fg)
    endif
    if a:bg != ""
        exec "hi ".a:group." guibg=#".a:bg." ctermbg=".<SID>rgb(a:bg)
    endif
    if a:attr != ""
        if a:attr == 'italic'
            exec "hi ".a:group." gui=".a:attr." cterm=none"
        else
            exec "hi ".a:group." gui=".a:attr." cterm=".a:attr
        endif
    endif
endfun

" ======== END FUNCTIONS ==================================================

call <SID>X("Normal",       "ffffff",   "242424",   "none")
call <SID>X("Cursor",       "708090",   "f0e68c",   "none")
            "CursorLine
            "CursorColumn
            "CursorIM
            "Question
            "IncSearch
call <SID>X("IncSearch",    "00ff00",   "000000",   "none")
call <SID>X("Search",       "000000",   "cd853f",   "none")
            "MatchParen"
call <SID>X("SpecialKey",	"9acd32",	      "",	"none")
call <SID>X("Visual",       "000000",   "ffaf00",   "none")
call <SID>X("LineNr",       "7f7f7f",   "2f2f2f",   "none")
call <SID>X("SignColumn",   "7f7f7f",   "2f2f2f",   "none")
call <SID>X("VertSplit",    "666666",   "c2bfa5",   "none")
call <SID>X("Folded",       "666666",   "000000",   "none")
call <SID>X("FoldColumn",   "333333",   "000000",   "none")
call <SID>X("ModeMsg",      "daa520",         "",   "none")
call <SID>X("MoreMsg",      "2e8b57",         "",   "none")
call <SID>X("NonText",      "4169e1",   "262626",   "none")
call <SID>X("Question",     "00ff7f",         "",   "none")
call <SID>X("StatusLine",   "000000",   "c2bfa5",   "none")
call <SID>X("StatusLineNC", "666666",   "c2bfa5",   "none")
call <SID>X("Title",        "ffd700",         "",   "none")
call <SID>X("Statement",    "6495ed",         "",   "none")
call <SID>X("WarningMsg",   "fa8072",         "",   "none")
call <SID>X("String",       "87ceeb",         "",   "none")
call <SID>X("Comment",      "666666",         "",   "none")
call <SID>X("Constant",     "ffa0a0",         "",   "none")
call <SID>X("Special",      "bdb76b",         "",   "none")
call <SID>X("Identifier",   "fa8072",         "",   "none")
call <SID>X("Include",      "ff0000",         "",   "none")
call <SID>X("PreProc",      "ff0000",   "ffffff",   "none")
call <SID>X("Operator",     "ff0000",         "",   "none")
call <SID>X("Define",       "ffd700",         "",   "none")
call <SID>X("Type",         "6495ed",         "",   "none")
call <SID>X("Function",     "ffdead",         "",   "none")
call <SID>X("Structure",    "00ff00",         "",   "none")
call <SID>X("Ignore",       "666666",         "",   "none")
call <SID>X("Todo",         "ff4500",   "eeee00",   "none")
call <SID>X("Directory",    "008b8b",         "",   "none")
call <SID>X("ErrorMsg",     "ffffff",   "ff0000",   "none")
            "VisualNOS
            "WildMenu
            "DiffAdd
            "DiffChange
            "DiffDelete
            "DiffText
            "Underlined
call <SID>X("Error",        "ffffff",   "ff0000",   "none")
call <SID>X("SpellErrors",  "ffffff",   "ff0000",   "none")
call <SID>X("Pmenu",        "000000",   "dfff00",   "none")
call <SID>X("PmenuSel",     "ffffff",   "444444",   "none")


" ==== DELETE FUNCTIONS ======
delf <SID>X
delf <SID>rgb
delf <SID>color
delf <SID>rgb_color
delf <SID>rgb_level
delf <SID>rgb_number
delf <SID>grey_color
delf <SID>grey_level
delf <SID>grey_number
" ============================
