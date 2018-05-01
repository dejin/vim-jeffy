" File: project.vim
" Author: Jeffy Du <jeffy.du@163.com>
" Version: 0.1
"
" Description:
" ------------
" This plugin provides a solution for creating project tags and cscope files.
" If you want to run this plugin in Win32 system, you need add the system-callings
" (ctags,cscope,find,grep,sort) to your system path. Usually, you can find these
" system-callings in Cygwin.
"
" Installation:
" -------------
" 1. Copy project.vim to one of the following directories:
"
"       $HOME/.vim/plugin    - Unix like systems
"       $VIM/vimfiles/plugin - MS-Windows
"
" 2. Start Vim on your project root path.
" 3. Use command ":ProjectCreate" to create project.
" 3. Use command ":ProjectLoad" to load project.
" 4. Use command ":ProjectUpdate" to update project.
" 5: Use command ":ProjectQuit" to quit project.

if exists('loaded_project')
    finish
endif
let loaded_project=1

if v:version < 700
    finish
endif

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

" Global variables
if !exists('g:project_data')
    "let g:project_data = ".project_vim"
    let g:project_data = "./"
endif

" WarnMsg                       {{{1
" display a warning message
function! s:WarnMsg(msg)
    echohl WarningMsg
    echon a:msg
    echohl None
endfunction

" ProjectCreate                 {{{1
" create project data
function! s:ProjectCreate()
    " create project data directory.
    if !isdirectory(g:project_data)
        call mkdir(g:project_data, "p")
    endif

    " create tags file
    if executable('ctags')
        call system('ctags -R --c++-kinds=+p --fields=+iaS --extra=+q -o ' . g:project_data . '/tags ' . getcwd())
    else
        call s:WarnMsg("command 'ctags' not exist.")
        return -1
    endif

    " create cscope file
    if executable('cscope')
        call system('cscope -Rbqk -f' . g:project_data . "/cscope.out")
    else
        call s:WarnMsg("command 'cscope' not exist.")
        return -1
    endif

    echon "create project done, "
    call s:ProjectLoad()
    return 1
endfunction


" ProjectUpdate                 {{{1
" update project data
function! s:ProjectUpdate()
    " find the project root directory.
    let proj_data = finddir(g:project_data, getcwd() . ',.;')
    if proj_data == ''
        return
    endif
    exe 'cd ' . proj_data

    " create tags file
    if executable('ctags')
        call system('ctags -R --c++-kinds=+p --fields=+iaS --extra=+q -o ' . proj_data . '/tags ' . getcwd())
    else
        call s:WarnMsg("command 'ctags' not exist.")
        return -1
    endif

    " create cscope file
    if executable('cscope')
        call system('cscope -Rbqk -f' . proj_data . "/cscope.out")
    else
        call s:WarnMsg("command 'cscope' not exist.")
        return -1
    endif

    echo "update project done."
    return 1
endfunction

" ProjectLoad                   {{{1
" load project data
function! s:ProjectLoad()
    " find the project root directory.
    let proj_data = finddir(g:project_data, getcwd() . ',.;')
    if proj_data == ''
        return
    endif
    exe 'cd ' . proj_data 

    " load tags.
    let &tags = proj_data . '/tags,' . &tags

    " load cscope.
    if filereadable(proj_data . '/cscope.out')
        set csto=1
        set cst
        set nocsverb
        exe 'cs add ' . proj_data . '/cscope.out'
        cs reset
        set csverb
    endif

    echon "load project done."
    return 1
endfunction

" ProjectQuit                   {{{1
" quit project
function! s:ProjectQuit()
    " find the project root directory.
    let proj_data = finddir(g:project_data, getcwd() . ',.;')
    if proj_data == ''
        return
    endif

    " quit vim
    exe 'qa'
    return 1
endfunction

" }}}

command! -nargs=0 -complete=file ProjectCreate call s:ProjectCreate()
command! -nargs=0 -complete=file ProjectUpdate call s:ProjectUpdate()
command! -nargs=0 -complete=file ProjectLoad call s:ProjectLoad()
command! -nargs=0 -complete=file ProjectQuit call s:ProjectQuit()

aug Project
    au VimEnter * call s:ProjectLoad()
    au VimLeavePre * call s:ProjectQuit()
    "au BufEnter,FileType c,cpp call s:HLUDColor()
aug END

nnoremap <leader>jc :ProjectCreate<cr>
nnoremap <leader>ju :ProjectUpdate<cr>
nnoremap <leader>jl :ProjectLoad<cr>
nnoremap <leader>jq :ProjectQuit<cr>

" restore 'cpo'
let &cpo = s:cpo_save
unlet s:cpo_save

