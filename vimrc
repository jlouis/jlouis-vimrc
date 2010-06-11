" This vimrc file owes much -- if not everything -- to Ciaran McCreesh.
" His configuration file was used for a start-point when building this one.

scriptencoding utf-8

"--- Terminal setup"

if (&term =~ "xterm") && (&termencoding == "")
    set termencoding=utf-8
endif

if &term =~ "xterm"
    " use xterm titles
    if has('title')
        set title
    endif

    " change cursor colour depending upon mode
    if exists('&t_SI')
        let &t_SI = "\<Esc>]12;lightgoldenrod\x7"
        let &t_EI = "\<Esc>]12;grey80\x7"
    endif
endif

"--- Settings"

set nocompatible
set enc=utf-8
set tenc=utf-8
set fileformat=unix
set viminfo='1000,f1,:1000,/1000
set history=500
set backspace=indent,eol,start
set backup
set showcmd
set showmatch
set hlsearch
set incsearch
set showfulltag
set expandtab
set lazyredraw
set noerrorbells
set ignorecase
set smartcase
set novisualbell
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
endif
set scrolloff=3
set sidescrolloff=2
set whichwrap+=<,>,[,]
set wildmenu
set wildignore+=*.o,*~,.lo
set suffixes+=.in,.a,.1
set hidden
set winminheight=1

let g:name = 'Jesper Louis Andersen'
let g:email = 'jesper.louis.andersen@gmail.com'

if has("syntax")
   syntax on
   set popt+=syntax:y
endif

set virtualedit=block,onemore
if hostname() == "illithid"
    set guifont=Inconsolata\ 10
elseif hostname() == "succubus"
    set guifont=Inconsolata\ 12
else
    set guifont=Inconsolata\ 12
endif

colorscheme inkpot

if has('gui')
    set guioptions-=m
    set guioptions-=T
    set guioptions-=l
    set guioptions-=L
    set guioptions-=r
    set guioptions-=R
end

set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
inoremap # X<BS>#

if has("folding")
    set foldenable
    set foldmethod=indent
    set foldlevelstart=99
endif

if has("eval")
    filetype on
    filetype plugin on
    filetype indent on
endif

if has("title")
    set title
endif

if has("title") && (has("gui_running") || &title)
    set titlestring=
    set titlestring+=%f\ " file name
    set titlestring+=%h%m%r%w
    set titlestring+=\ -\ %{v:progname}
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}
endif

set grepprg=grep\ -nH\ $*
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15
let g:tex_flavor='latex'
set iskeyword+=:
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\                          " file name

if has("eval")
    let g:scm_cache = {}
    fun! ScmInfo()
        let l:key = getcwd()
        if ! has_key(g:scm_cache, l:key)
            if (isdirectory(getcwd() . "/.git"))
                let g:scm_cache[l:key] = "[" . substitute(readfile(getcwd() . "/.git/HEAD", "", 1)[0],
                            \ "^.*/", "", "") . "] "
            else
                let g:scm_cache[l:key] = ""
            endif
        endif
        return g:scm_cache[l:key]
    endfun
    set statusline+=%{ScmInfo()}             " scm info
endif
set statusline+=%h%1*%m%r%w%0*               " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=%{&encoding},                " encoding
set statusline+=%{&fileformat}]              " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()}          " vim buddy
endif
set statusline+=%=                           " right align
set statusline+=%2*0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset
 
" special statusbar for special windows
if has("autocmd")
    au FileType qf
                \ if &buftype == "quickfix" |
                \     setlocal statusline=%2*%-3.3n%0* |
                \     setlocal statusline+=\ \[Compiler\ Messages\] |
                \     setlocal statusline+=%=%2*\ %<%P |
                \ endif

    fun! <SID>FixMiniBufExplorerTitle()
        if "-MiniBufExplorer-" == bufname("%")
            setlocal statusline=%2*%-3.3n%0*
            setlocal statusline+=\[Buffers\]
            setlocal statusline+=%=%2*\ %<%P
        endif
    endfun

    au BufWinEnter *
                \ let oldwinnr=winnr() |
                \ windo call <SID>FixMiniBufExplorerTitle() |
                \ exec oldwinnr . " wincmd w"
endif


" If possible and in gvim, use cursor row highlighting
if has("gui_running") && v:version >= 700
    set cursorline
end
set guicursor+=a:blinkon0

if has("file_in_path")
    let &cdpath=','.expand("$HOME").','.expand("$HOME").'/work'
endif

" Better include path handling
set path+=src/
let &inc.=' ["<]'

" Show tabs and trailing whitespace visually
if (&termencoding == "utf-8") || has("gui_running")
    if v:version >= 700
        if has("gui_running")
            set list listchars=tab:»·,trail:·,extends:…,nbsp:‗
        else
            " xterm + terminus hates these
            set list listchars=tab:»·,trail:·,extends:>,nbsp:_
        endif
    else
        set list listchars=tab:»·,trail:·,extends:…
    endif
else
    if v:version >= 700
        set list listchars=tab:>-,trail:.,extends:>,nbsp:_
    else
        set list listchars=tab:>-,trail:.,extends:>
    endif
endif

set fillchars=fold:-

" Filter expected errors from make
if has("eval") && v:version >= 700
    if hostname() == "succubus"
        let &makeprg="nice -n7 make -j1 2>&1"
    elseif hostname() == "illithid"
        let &makeprg="nice -n7 make -j2 2>&1"
    else
        let &makeprg="nice -n7 make -j2 2>&1"
    endif

    " ignore libtool links with version-info
    let &errorformat="%-G%.%#libtool%.%#version-info%.%#,".&errorformat

    " ignore doxygen things
    let &errorformat="%-G%.%#Warning: %.%# is not documented.,".&errorformat
    let &errorformat="%-G%.%#Warning: no uniquely matching class member found for%.%#,".&errorformat
    let &errorformat="%-G%.%#Warning: documented function%.%#was not declared or defined.%.%#,".&errorformat
 
    " catch internal errors
    let &errorformat="%.%#Internal error at %.%# at %f:%l: %m,".&errorformat
endif

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
set dictionary=/usr/share/dict/words
 
"-----------------------------------------------------------------------
" autocmds
"-----------------------------------------------------------------------
 
if has("eval")
 
    " If we're in a wide window, enable line numbers.
    fun! <SID>WindowWidth()
        if winwidth(0) > 90
            setlocal number
            setlocal foldcolumn=0
        else
            setlocal nonumber
            setlocal foldcolumn=0
        endif
    endfun
 
    " Force active window to the top of the screen without losing its
    " size.
    fun! <SID>WindowToTop()
        let l:h=winheight(0)
        wincmd K
        execute "resize" l:h
    endfun
endif

" autocmds
if has("autocmd") && has("eval")
    augroup jlouis
        autocmd!
 
        " Automagic line numbers
        autocmd BufEnter * :call <SID>WindowWidth()
 
        " Always do a full syntax refresh
        autocmd BufEnter * syntax sync fromstart
 
        " For help files, move them to the top window and make <Return>
        " behave like <C-]> (jump to tag)
        autocmd FileType help :call <SID>WindowToTop()
        autocmd FileType help nmap <buffer> <Return> <C-]>
 
        " For svn-commit, don't create backups
        autocmd BufRead svn-commit.tmp :setlocal nobackup
 
        " m4 matchit support
        autocmd FileType m4 :let b:match_words="(:),`:',[:],{:}"
 
        " Detect procmailrc
        autocmd BufRead procmailrc :setfiletype procmail
 
        " bash-completion ftdetects
        autocmd BufNewFile,BufRead /*/*bash*completion*/*
                    \ if expand("<amatch>") !~# "ChangeLog" |
                    \     let b:is_bash = 1 | set filetype=sh |
                    \ endif

        try
            autocmd QuickFixCmdPost * botright cwindow 5
        catch
        endtry

        try
            autocmd Syntax *
                        \ syn match VimModelineLine /^.\{-1,}vim:[^:]\{-1,}:.*/ contains=VimModeline |
                        \ syn match VimModeline contained /vim:[^:]\{-1,}:/
            hi def link VimModelineLine comment
            hi def link VimModeline     special
        catch
        endtry
    augroup END
endif
 
" content creation
if has("autocmd")
    augroup content
        autocmd!
 
        autocmd BufNewFile *.rb 0put ='# vim: set sw=4 sts=4 et tw=80 :' |
                    \ 0put ='#!/usr/bin/ruby' | set sw=4 sts=4 et tw=80 |
                    \ norm G
 
        autocmd BufNewFile *.hh 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ 1put ='' | call MakeIncludeGuards() |
                    \ set sw=4 sts=4 et tw=80 | norm G
 
        autocmd BufNewFile *.cc 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ 1put ='' | 2put ='' | call setline(3, '#include "' .
                    \ substitute(expand("%:t"), ".cc$", ".hh", "") . '"') |
                    \ set sw=4 sts=4 et tw=80 | norm G
    augroup END
endif

" Functions
func GitGrep(...)
    let save=&grepprg
    set grepprg=git\ grep\ -n\ $*
    let s = 'grep'
    for i in a:000
	let s = s . ' ' . i
    endfor
    exe s
    let &grepprg = save
endfun

func Blue(...)
    hi Normal guifg=#ffe97a guibg=#00002b
endfun

func Green(...)
    hi Normal guifg=#ffe97a guibg=#002b00
endfun

" Mappings
nmap <F12> :make<CR>
map <F1> <Esc>
imap <F1> <Esc>
command -nargs=? G call GitGrep(<f-args>)
" vim: set shiftwidth=4 softtabstop=4 expandtab tw=120                 :

" Various UTF-8 mappings
" Superscripts
imap <buffer> ^0 ⁰
imap <buffer> ^1 ¹
imap <buffer> ^2 ²
imap <buffer> ^3 ³
imap <buffer> ^4 ⁴
imap <buffer> ^5 ⁵
imap <buffer> ^6 ⁶
imap <buffer> ^7 ⁷
imap <buffer> ^8 ⁸
imap <buffer> ^9 ⁹
imap <buffer> ^+ ⁺
imap <buffer> ^- ⁻
imap <buffer> ^= ⁼
imap <buffer> ^( ⁽
imap <buffer> ^) ⁾
imap <buffer> ^n ⁿ

" Subscripts
imap <buffer> \_0 ₀
imap <buffer> \_1 ₁
imap <buffer> \_2 ₂
imap <buffer> \_3 ₃
imap <buffer> \_4 ₄
imap <buffer> \_5 ₅
imap <buffer> \_6 ₆
imap <buffer> \_7 ₇
imap <buffer> \_8 ₈
imap <buffer> \_9 ₉
imap <buffer> \_+ ₊
imap <buffer> \_- ₋
imap <buffer> \_= ₌
imap <buffer> \_( ₍

" Arrows
imap <buffer> \-> →
imap <buffer> \<-- ←
imap <buffer> \<--> ↔
imap <buffer> \==> ⇒
imap <buffer> \<== ⇐
imap <buffer> \<==> ⇔
"
" Symbols from mathematics and logic, LaTeX style
imap <buffer> \forall ∀
imap <buffer> \exists ∃
imap <buffer> \in ∈
imap <buffer> \ni ∋
imap <buffer> \empty ∅
imap <buffer> \prod ∏
imap <buffer> \sum ∑
imap <buffer> \le ≤
imap <buffer> \ge ≥
imap <buffer> \pm ±
imap <buffer> \subset ⊂
imap <buffer> \subseteq ⊆
imap <buffer> \supset ⊃
imap <buffer> \supseteq ⊇
imap <buffer> \setminus ∖
imap <buffer> \cap ∩
imap <buffer> \cup ∪
imap <buffer> \int ∫
imap <buffer> \therefore ∴
imap <buffer> \qed ∎
imap <buffer> \1 𝟙
imap <buffer> \N ℕ
imap <buffer> \Z ℤ
imap <buffer> \C ℂ
imap <buffer> \Q ℚ
imap <buffer> \R ℝ
imap <buffer> \E 𝔼
imap <buffer> \F 𝔽
imap <buffer> \to →
imap <buffer> \mapsto ↦
imap <buffer> \infty ∞
imap <buffer> \cong ≅
imap <buffer> \:= ≔
imap <buffer> \=: ≕
imap <buffer> \ne ≠
imap <buffer> \approx ≈
imap <buffer> \perp ⊥
imap <buffer> \not ̷
imap <buffer> \ldots …
imap <buffer> \cdots ⋯
imap <buffer> \cdot ⋅
imap <buffer> \circ ◦
imap <buffer> \times ×
imap <buffer> \oplus ⊕
imap <buffer> \langle ⟨
imap <buffer> \rangle ⟩

" Greek alphabet...
imap <buffer> \alpha α
imap <buffer> \beta β
imap <buffer> \gamma γ
imap <buffer> \delta δ
imap <buffer> \epsilon ε
imap <buffer> \zeta ζ
imap <buffer> \nu η
imap <buffer> \theta θ
imap <buffer> \iota ι
imap <buffer> \kappa κ
imap <buffer> \lambda λ
imap <buffer> \mu μ
imap <buffer> \nu ν
imap <buffer> \xi ξ
imap <buffer> \omicron ο
imap <buffer> \pi π
imap <buffer> \rho ρ
imap <buffer> \stigma ς
imap <buffer> \sigma σ
imap <buffer> \tau τ
imap <buffer> \upsilon υ
imap <buffer> \phi ϕ
imap <buffer> \varphi φ
imap <buffer> \chi χ
imap <buffer> \psi ψ
imap <buffer> \omega ω

imap <buffer> \Alpha Α
imap <buffer> \Beta Β
imap <buffer> \Gamma Γ
imap <buffer> \Delta Δ
imap <buffer> \Epsilon Ε
imap <buffer> \Zeta Ζ
imap <buffer> \Nu Η
imap <buffer> \Theta Θ
imap <buffer> \Iota Ι
imap <buffer> \Kappa Κ
imap <buffer> \Lambda Λ
imap <buffer> \Mu Μ
imap <buffer> \Nu Ν
imap <buffer> \Xi Ξ
imap <buffer> \Omicron Ο
imap <buffer> \Pi Π
imap <buffer> \Rho Ρ
imap <buffer> \Sigma Σ
imap <buffer> \Tau Τ
imap <buffer> \Upsilon Υ
imap <buffer> \Phi Φ
imap <buffer> \Chi Χ
imap <buffer> \Psi Ψ
imap <buffer> \Omega Ω

