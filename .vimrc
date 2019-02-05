" Vim 8, prevents defaults.vim from being sourced
let skip_defaults_vim = 1
" Do not keep compatibility with Vi, use all of Vim's features
set nocompatible
set hlsearch
" Do not use select mode, only use visual mode (see next option)
set selectmode=
" This option controls the behaviour of the buttons when selecting
" text.  I dont like selectmode, since it is useless <g>.  Using
" visual mode all the time when selecting text allows you to perform
" a lot more functions over the selected range.
" selectmode is really there to make Vim more like Windows.
" This also forces the buttons on the mouse to perform like Unix, not
" Windows
behave xterm
set cursorline
set cursorcolumn
set laststatus=2
set shortmess=at
set whichwrap=<,>,h,l
set history=500
set nobackup
set nowritebackup
set incsearch
set showcmd
set showbreak=>>
set nostartofline
set joinspaces
set nrformats-=octal
set ignorecase smartcase
set virtualedit=
set modelines=10
set shiftwidth=4
set nodigraph
set esckeys
set hidden
set ruler
set showmatch
set visualbell
set wildmenu
set noerrorbells
set autoindent
set autochdir
set foldopen+=jump
set hidden
set expandtab
set tabstop=4
set lines=42
set columns=160

" characters used to represent invisibles
set listchars+=tab:»\         " 187 followed by a space (032) (and no, it
                        " doesn't *need* to be escaped with a
                        " backslash on Windows or Linux)
set listchars+=eol:¶          " 182
set listchars+=trail:·        " 183
if has("win32")
     set listchars+=extends:…  " 133
     set listchars+=precedes:… " 133
elseif has("unix")
     set listchars+=extends:_  " underscore (095)
     set listchars+=precedes:_ " underscore (095)
endif
set nolist
nnoremap <F4> :set list!<CR>   " Toggle showing unprintable characters
nnoremap <F7> :nohlsearch<CR>   " Toggle highlighting searches 


syntax on
filetype on
filetype plugin on
colorscheme murphy
" VimInfo
" \"50      - save only the first 50 lines of each register
" '1000     - save 1000 local marks
" h         - disable 'hlsearch' highlighting when starting
" f1        - global marks are stored A - Z
" rA:       - A: is a removable media, dont store stuff about it
" r...:     - ...=directory, $TEMP: are temporary files, dont store stuff about it
" :500      - lines of history
" /500      - size of the search history
" !         - save and restore global variables
" n...      - viminfo file name and location
set viminfo=\"50,'1000,h,f1,rA:,r$TEMP:,r$TMP:,r$TMPDIR:,:500,/500,!,n$HOME/.viminfo
" Avoid command-line redraw on every entered character                                                                                                                                         
" by turning off Arabic shaping
if has('arabic')
    set noarabicshape
endif
if has('linux')
    set fileformats=unix,dos,mac      " Leave files in Unix format first
elseif has('macunix')
    set fileformats=mac,unix,dos      " Leave files in Mac format first
else
    set fileformats=dos,unix,mac      " Leave files in DOS format first
endif
" Concatenated from many different posts
" Bufnr, status, filename, filetype
" Total lines, percentage through file
" Column nbr -
" (next line percentage of line)
" - truncate if too long, followed by Byte, Ascii, and total lines
" let statusline='B:%n%m %f%r%y'      
"             \ . ' %=L:%l -%P-'
"             \ . ' %=C:%c%V -'     
"             \ . "%03{((col('.')-(mode()=='i'?1:0))*100)/(strlen(getline('.'))?strlen(getline('.')):1).'%'}"
"             \ . '-%< Byte:%o Chr:%B L#:%L' 


" filename %-.50f --> maximum 50 rightmost characters of filename, this is
"                     useful if the fullpath is displayed, then
" readonly(r), filetype(y), modified(m)
" bufnr(n)
" Line(l), Column(c), VirtualColumn(V)  percentage through file(p)
let statusline=' %-.50f%r%y%m'      
            \ . ' B:%n'
            \ . '%=%l,%c%V %p%%'     
let &statusline=statusline

" To get the full directory of the file you are editing
cnoreabbrev CD <C-R>=expand('%:p:h')<CR>


" Visually select text, then search for it (escaping as necessary)
" http://vim.wikia.com/wiki/Search_for_visually_selected_text
if version >= 602
    " Here are two enhanced versions of these mappings which use VIM 6.2's
    " getregtype() function to determine whether the unnamed register contains
    " a characterwise, linewise or blockwise selection. After the search has
    " been executed, the register *and* its type can then be restored with
    " setreg().
    " See also:
    " http://vim.wikia.com/wiki/Search_for_visually_selected_text
    vnoremap <silent> * :<C-U>
                  \let old_reg=getreg('"')<bar>
                  \let old_regmode=getregtype('"')<cr>
                  \gvy/<C-R><C-R>=substitute(substitute(
                  \escape(@", '\\/.*$^~[]' ), "\n$", "", ""),
                  \"\n", '\\_[[:return:]]', "g")<cr><cr>
                  \:call setreg('"', old_reg, old_regmode)<cr>
    vnoremap <silent> # :<C-U>
                  \let old_reg=getreg('"')<bar>
                  \let old_regmode=getregtype('"')<cr>
                  \gvy?<C-R><C-R>=substitute(substitute(
                  \escape(@", '\\/.*$^~[]' ), "\n$", "", ""),
                  \"\n", '\\_[[:return:]]', "g")<cr><cr>
                  \:call setreg('"', old_reg, old_regmode)<cr>
else
    " If you use both VIM 6.2 and older versions these mappings
    " should be defined depending on the current version.
    vnoremap <silent> * :<C-U>let old_reg=@"<cr>
                  \gvy/<C-R><C-R>=substitute(substitute(
                  \escape(@", '\\/.*$^~[]' ), "\n$", "", ""),
                  \"\n", '\\_[[:return:]]', "g")<cr><cr>
                  \:let @"=old_reg<cr>
    vnoremap <silent> # :<C-U>let old_reg=@"<cr>
                  \gvy?<C-R><C-R>=substitute(substitute(
                  \escape(@", '\\/.*$^~[]' ), "\n$", "", ""),
                  \"\n", '\\_[[:return:]]', "g")<cr><cr>
                  \:let @"=old_reg<cr>
endif


" The Vim distribution allows you to specify which type of SQL you want to
" default to.  There are many choices, but the standard one is:
" sqloracle, sqlanywhere, sqlinformix, tsql_sql, ....
" This option allows you to specify your default type.
let g:sql_type_default = 'sqlanywhere'
" To change this temporarily for a buffer you can use:
" :SQLSetType
" :SQL<tab> <tab>  - will list the options available to choose from
" :SQLSetType      - with no parameter, restored to default (Oracle) 

set diffexpr=MyDiff()
function! MyDiff()
    " To run diff from the command line you can do the following
    " gvim -d -O left_file right_file
    let opt = ' '
    if &diffopt =~ 'icase'
        let opt = opt . '-i '
    endif
    if &diffopt =~ 'iwhite'
        let opt = opt . '-b '
    endif
    let diff_bin = 'diff'
    if filereadable(expand('$VIM').'/Tools/diff')
        let diff_bin = expand('$VIM').'/Tools/diff'
    endif
    silent execute '!'.diff_bin.' -a ' .
                \ opt . v:fname_in . ' ' .
                \ v:fname_new . ' > ' . v:fname_out
endfunction


" echo winwidth(0) winwidth(1) winwidth(2) winwidth(3)


" Suggested minimal plugins:


" BufExplorer mappings  /*{{{*/
 " Author: Jeff Lanzarotta
 " http://vim.sourceforge.net/script.php?script_id=42
 " \be initiates it (default mapping)
 nnoremap <silent> <Leader>bb :BufExplorer<CR>
 " Buffer Explorers /*}}}*/ 



" YankRing - Maintains a list of recently yanked/deleted items :/*{{{*/
 " Authors: David Fishburn
 " http://vim.sourceforge.net/script.php?script_id=1234
 " Do not map the default <C-N> and <C-P> keys
 " These two characters are the ALT-< and ALT->.
 " To determine what character # these are go into insert mode
 " in a new buffer.  Press CTRL-V then ALT and the > key.
 " Leave insert mode, move the cursor onto the character
 " and press ga.  This will display the decimal, hex and octal
 " representation of the character.  In this case, they are
 " 172 and 174.
 if has('win32')
     let g:yankring_replace_n_pkey = '<Char-172>'
     let g:yankring_replace_n_nkey = '<Char-174>'
     " Instead map these keys to moving through items in the quickfix window.
     nnoremap <C-N> :cn<cr>
     nnoremap <C-P> :cp<cr>
 endif 


" /*}}}*/ 


" MRU - Most Recently Used options:/*{{{*/
 " http://vim.sourceforge.net/script.php?script_id=521
 let MRU_Max_Entries = 500
 " Exclude storing any:
 "      a) temporary files ($TEMP)
 "      b) temporary internet files
 "      c) files created by Xnews
 "      d) files created by Mutt
 let MRU_Exclude_Files = '\c^c:\\WINDOWS\\temp\\.*\|temp\|Temporary\|__edit_\|mutt_fishburn'
 " let MRU_Exclude_Files = '^/tmp/.*\|^/var/tmp/.*'
 " " Unix (notice the added '^') in order not to match tmp anywhere.
 let MRU_File = (has('win32')?expand('$VIM'):expand('$HOME')).'/mru_list.txt'
 " Sometimes it is useful to use MRU to get to a filename that
 " is close to what you want and then edit the file name.
 " But you then need to flip :MRU to :e, this cmap will
 " perform the replacement at a key stroke.
 cmap <C-e> <C-\>esubstitute(getcmdline(), '^MRU\>', 'e', '')<CR>
 " /*}}}*/ 




" TagBar: Display tags of the current file ordered by scope  /*{{{*/
 " http://vim.sourceforge.net/script.php?script_id=3465
 " Author: Jan Larres
 " Nearly identical to TagList, but uses scope
 " Make sure ctags.exe is in the PATH
 let g:tagbar_left      = 1
 let g:tagbar_width     = 65
 let g:tagbar_autoclose = 1
 nmap <F8> :TagbarToggle<CR> 


" Flex language
 let g:tagbar_type_actionscript = {
             \ 'ctagstype' : 'flex',
             \ 'kinds' : [
             \ 'f:functions',
             \ 'c:classes',
             \ 'm:methods',
             \ 'p:properties',
             \ 'v:global variables',
             \ 'x:mxtags'
             \ ]
             \ }
 let g:tagbar_type_mxml = {
             \ 'ctagstype' : 'flex',
             \ 'kinds' : [
             \ 'f:functions',
             \ 'c:classes',
             \ 'm:methods',
             \ 'p:properties',
             \ 'v:global variables',
             \ 'x:mxtags'
             \ ]
             \ }
 let g:tagbar_type_sql  = {
             \ 'ctagstype' : 'sql',
             \ 'kinds'     : [
             \ 'f:functions',
             \ 'P:packages',
             \ 'p:procedures',
             \ 't:tables',
             \ 'T:triggers',
             \ 'v:variables',
             \ 'e:events',
             \ 'U:publications',
             \ 'R:services',
             \ 'D:domains',
             \ 'x:MLTableScripts',
             \ 'y:MLConnScripts',
             \ 'z:MLProperties',
             \ 'i:indexes',
             \ 'c:cursors',
             \ 'V:views',
             \ 'd:prototypes'
             \ ]
             \ }
             " \ 'l:local variables',
             " \ 'F:record fields',
             " \ 'L:block label',
             " \ 'r:records',
             " \ 's:subtypes'
 " Override the default SQL categories to use what is in the
 " c:\ctags.cnf file
 " Added additional support for Mambo PHP modules which have an
 " $action passed to them (which are essentially functions)
 let g:tagbar_type_php  = {
             \ 'ctagstype' : 'php',
             \ 'kinds'     : [
             \ 'c:class',
             \ 'f:function',
             \ 'd:constants',
             \ 'A:action'
             \ ]
             \ }
 " Extended javascript to deal with
 "     this.saveSettings = function()
 let g:tagbar_type_javascript  = {
             \ 'ctagstype' : 'javascript',
             \ 'kinds'     : [
             \ 'f:functions',
             \ 'c:classes',
             \ 'm:methods',
             \ 'p:properties',
             \ 'v:global variables'
             \ ]
             \ }
 " Extended DOS batch files to deal with
 "     :SOME_LABEL_NAME
 let g:tagbar_type_dosbatch  = {
             \ 'ctagstype' : 'dosbatch',
             \ 'kinds'     : [
             \ 'l:label',
             \ 'v:variable'
             \ ]
             \ }
 " Tex language
 let g:tagbar_type_tex  = {
             \ 'ctagstype' : 'tex',
             \ 'kinds'     : [
             \ 'p:parts',
             \ 'c:chapters',
             \ 's:sections',
             \ 'u:subsections',
             \ 'b:subsubsections',
             \ 'P:paragraphs',
             \ 'G:subparagraphs',
             \ 'l:labels',,b
             \ 'i:includes'
             \ ]
             \ }
 " MatLab language
 let g:tagbar_type_matlab  = {
             \ 'ctagstype' : 'matlab',
             \ 'kinds'     : [
             \ 'f:functions'
             \ ]
             \ }
 " Ant language
 let g:tagbar_type_ant  = {
             \ 'ctagstype' : 'ant',
             \ 'kinds'     : [
             \ 'p:Project',
             \ 't:Target'
             \ ]
             \ }
 " Ant language
 let g:tagbar_type_vim  = {
             \ 'ctagstype' : 'vim',
             \ 'kinds'     : [
             \ 'p:Project',
             \ 'a:autocommand groups',
             \ 'c:user-defined commands',
             \ 'f:function definitions',
             \ 'm:maps',
             \ 'v:variable definitions',
             \ 'n:vimball filename'
             \ ]
             \ }
 " /*}}}*/ 



" dbext - SQL/Database mappings:/*{{{*/
 " Authors: Peter Bagyinski
 "          David Fishburn
 " http://vim.sourceforge.net/script.php?script_id=356
 let g:dbext_default_profile_ASA = 'type=ASA:user=dba:passwd=sql'
 let g:dbext_default_profile = 'ASA'
 let g:dbext_default_profile_ASA_Vantage_SAAP_DBI = 'type=DBI:user=saap:passwd=sql:driver=SQLAnywhere:conn_parms=DSN=SAAP_rem_0101'
 "let g:dbext_default_profile_ASA_DBI              = 'type=DBI:user=dba:passwd=sql:driver=SQLAnywhere:conn_parms=:driver_parms=LongReadLen=1000000'
 let g:dbext_default_profile_ASA_Vantage_SAAP_ODBC = 'type=ODBC=saap:passwd=sql:dsnname=SAAP_rem_0101:conn_parms=ConnectionName=dbext' 


" Maintain history between different startup and shutdown of Vim
 " let g:dbext_default_history_size = 11
 " Besides the documented defaults for variable definitions
 "    {\w\+}Wq
 "    For PHP files handle variables of this format
 "        "select * from employee where name = {var_name} "
 "    {\w\+}   - a word surrounded by curly braces
 "    W        - cannot have word characters after the braces
 "    q        - quotes do not matter
 " I have added an additional one for SQL Anywhere's web services
 "    http_varu)
 "    For SQL as:
 "        WHERE ID = http_variable(''cust_id'')
 "    http_var - begins with this string
 "    u        - until
 "    )        - this string should be included in the replacement
 " For the OneBridge server variables
 " let g:dbext_default_variable_def = '?WQ,@wq,:wq,$wq,i%wqi%,{\w\+}Wq,http_varu)'
 let g:dbext_default_variable_def = '?WQ,@wq,:wq,$wq,{\w\+}Wq,http_varu)' 


" autoload/sqlcomplete option for table completion
 " Do NOT show table owners
 let g:dbext_default_dict_show_owner = 0
 let g:omni_sql_include_owner = 0 


" Since I repeatedly need to edit stored procedures, the CREATE PROCEDURE
 " statement is preceeded by an IF ... END IF block which will drop
 " the procedure or it uses the CREATE OR REPLACE syntax.  A third alternative
 " is an ALTER PROCEDURE statement.
 " This function will visually select the IF block to the END; statement
 " of the stored procedure and execute it.  Or check for the
 " CREATE OR REPLACE and stop there and look to the end.
 " Here are the 3 structures this will look for (all from column 0):
 " Case 1:
 "     IF ..
 "     END IF;
 "     CREATE PROCEDURE
 "     BEGIN
 "     END;
 " Case 2:
 "     CREATE OR REPLACE PROCEDURE
 "     BEGIN
 "     END;
 " Case 3:
 "     ALTER PROCEDURE
 "     BEGIN
 "     END;
 "
 function! SQLExecuteIfCreateReplace() "{{{
     let l:old_sel = &sel
     let &sel = 'inclusive'
     let saveWrapScan=&wrapscan
     let saveSearch=@/
     let l:reg_z = @z
     let &wrapscan=0
     let @z = ''
     let found = 0
     let startLine = 0
     let endLine = 0
     let curLine = line(".")
     let curCol  = virtcol(".") 


    " Must default the command terminator
     let l:dbext_cmd_terminator = ";" 


    try
         " Search backwards and do NOT wrap
         " Find the line beginning with an IF clause
         "     IF EXISTS( SELECT 1 ...
         " or find an or replace clause
         "     CREATE OR REPLACE PROCEDURE ...
         " or find an ALTER PROCEDURE
         "     CREATE OR REPLACE PROCEDURE ...
         " And execute it until we find an
         "     END
         " at the beginning of a line.
         let startLine = search('\c\(^\<if\>\|^\<alter\s\+procedure\>\|\<or\s\+replace\>\)', 'bcnW' ) 


        if startLine > 0
             " Search forward and visually select all lines
             " until we find an END; clause
             " exe 'silent! norm! V/^END'.l:dbext_cmd_terminator."\s*$\n\<esc>"
             let endLine = search('^END'.l:dbext_cmd_terminator.'\s*$', 'cnW')
             exec startLine.','.endLine.'DBExecRangeSQL'
         endif
     finally
      call cursor(curLine, curCol)
         noh
         let l:query = @z
         let @z = l:reg_z
         let @/=saveSearch
         let &wrapscan=saveWrapScan
         let &sel = l:old_sel
     endtry
 endfunction "}}}
 nnoremap <Leader>sbe :call SQLExecuteIfCreateReplace()<CR>
 " /*}}}*/ 
