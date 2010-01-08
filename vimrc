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
set viminfo='1000,f1,:1000,/1000
set history=500
set backspace=indent,eol,start
set backup
set showcmd
set showmatch
set hlsearch
set incsearch
set showfulltag
set lazyredraw
set noerrorbells
set ignorecase
set smartcase
set visualbell t_vb=
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

if has("syntax")
    syntax on
endif
set virtualedit=block,onemore
if hostname() == "illithid"
    set guifont=Inconsolata\ 11
elseif hostname() == "succubus"
    set guifont=Inconsolata\ 8
else
    set guifont=Inconsolata\ 11
endif

set background=dark
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
set popt+=syntax:y
if has("eval")
    filetype on
    filetype plugin on
    filetype indent on
endif
set nomodeline
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15
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

" Nice window title
if has('title') && (has('gui_running') || &title)
    set titlestring=
    set titlestring+=%f\                                              " file name
    set titlestring+=%h%m%r%w                                         " flags
    set titlestring+=\ -\ %{v:progname}                               " program name
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

" If possible, try to use a narrow number column.
if v:version >= 700
    try
        setlocal numberwidth=3
    catch
    endtry
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
 
    " paludis things
    let &errorformat="%-G%.%#test_cases::FailTest::run()%.%#,".&errorformat
    let &errorformat="%-G%.%#%\\w%\\+/%\\w%\\+-%[a-zA-Z0-9.%\\-_]%\\+:%\\w%\\+::%\\w%\\+%.%#,".&errorformat
    let &errorformat="%-G%.%#Writing VDB entry to%.%#,".&errorformat
    let &errorformat="%-G%\\(install%\\|upgrade%\\)_TEST> %.%#,".&errorformat

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
 
    if v:version >= 700
        " Load gcov marks
        hi UncoveredSign guibg=#2e2e2e guifg=#e07070
        hi CoveredSign guibg=#2e2e2e guifg=#70e070
        sign define uncovered text=## texthl=UncoveredSign
        sign define covered text=## texthl=CoveredSign
        fun! <SID>LoadGcovMarks()
            if ! filereadable(expand("%").".gcov")
                return
            endif
            sign unplace *
            for l:x in map(map(filter(readfile(expand("%").".gcov"),
                        \ '! match(v:val, "^\\s*#\\+:")'),
                        \ 'substitute(v:val,"^[^:]\\+:\\s*\\(\\d\\+\\):.*","\\1","")'),
                        \ '":sign place " . v:val . " line=" . v:val . " name=uncovered " .
                        \ "file=" . expand("%")')
                exec l:x
            endfor
            for l:x in map(map(filter(readfile(expand("%").".gcov"),
                        \ '! match(v:val, "^\\s*\\d\\+:")'),
                        \ 'substitute(v:val,"^[^:]\\+:\\s*\\(\\d\\+\\):.*","\\1","")'),
                        \ '":sign place " . v:val . " line=" . v:val . " name=covered " .
                        \ "file=" . expand("%")')
                exec l:x
            endfor
        endfun
 
        fun! <SID>UpdateCopyrightHeaders()
            let l:a = 0
            for l:x in getline(1, 10)
                let l:a = l:a + 1
                if -1 != match(l:x, 'Copyright (c) [- 0-9,]*200[456789] Ciaran McCreesh')
                    if input("Update copyright header? (y/N) ") == "y"
                        call setline(l:a, substitute(l:x, '\(20[01][456789]\) Ciaran',
                                    \ '\1, 2010 Ciaran', ""))
                    endif
                endif
            endfor
        endfun
    endif
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
 
        " load gcov for c++ files
        autocmd FileType cpp call <SID>LoadGcovMarks()
 
        " update copyright headers
        autocmd BufWritePre * call <SID>UpdateCopyrightHeaders()
 
        try
            " if we have a vim which supports QuickFixCmdPost (vim7),
            " give us an error window after running make, grep etc, but
            " only if results are available.
            autocmd QuickFixCmdPost * botright cwindow 5
 
            autocmd QuickFixCmdPre make
                        \ let g:make_start_time=localtime()
 
            let g:paludis_configure_command = "! ./configure --prefix=/usr --sysconfdir=/etc" .
                        \ " --localstatedir=/var/lib --enable-qa " .
                        \ " --enable-ruby --enable-python --enable-vim --enable-bash-completion" .
                        \ " --enable-zsh-completion --with-repositories=all --with-clients=all --with-environments=all" .
                        \ " --enable-visibility --enable-gnu-ldconfig --enable-htmltidy" .
                        \ " --enable-ruby-doc --enable-python-doc --enable-xml"
 
            " Similarly, try to automatically run ./configure and / or
            " autogen if necessary.
            autocmd QuickFixCmdPre make
                        \ if ! filereadable('Makefile') |
                        \     if ! filereadable("configure") |
                        \         if filereadable("autogen.bash") |
                        \             exec "! ./autogen.bash" |
                        \         elseif filereadable("quagify.sh") |
                        \             exec "! ./quagify.sh" |
                        \         endif |
                        \     endif |
                        \     if filereadable("configure") |
                        \         if (isdirectory(getcwd() . "/paludis/util")) |
                        \             exec g:paludis_configure_command |
                        \         elseif (match(getcwd(), "libwrapiter") >= 0) |
                        \             exec "! ./configure --prefix=/usr --sysconfdir=/etc" |
                        \         else |
                        \             exec "! ./configure" |
                        \         endif |
                        \     endif |
                        \ endif
 
            autocmd QuickFixCmdPost make
                        \ let g:make_total_time=localtime() - g:make_start_time |
                        \ echo printf("Time taken: %dm%2.2ds", g:make_total_time / 60,
                        \     g:make_total_time % 60)
 
            autocmd QuickFixCmdPre *
                        \ let g:old_titlestring=&titlestring |
                        \ let &titlestring="[ " . expand("<amatch>") . " ] " . &titlestring |
                        \ redraw
 
            autocmd QuickFixCmdPost *
                        \ let &titlestring=g:old_titlestring
 
            if hostname() == "snowmobile"
                autocmd QuickFixCmdPre make
                            \ let g:active_line=getpid() . " vim:" . substitute(getcwd(), "^.*/", "", "") |
                            \ exec "silent !echo '" . g:active_line . "' >> ~/.config/awesome/active"
 
                autocmd QuickFixCmdPost make
                            \ exec "silent !sed -i -e '/^" . getpid() . " /d' ~/.config/awesome/active"
            endif
 
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

" Mappings
nmap <F12> :make<CR>

" vim: set shiftwidth=4 softtabstop=4 expandtab tw=120                 :

