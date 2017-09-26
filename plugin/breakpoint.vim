highlight Breakpoint ctermfg=Red

sign define breakpoint text=* texthl=Breakpoint

" This is so my sign numbering (hopefully) doesn't collide
" with some other plugin
let g:breakpoint#counterOffset = 2000
let s:counter = g:breakpoint#counterOffset + 1

let g:breakpoints = []

" retuns a string containing the name of the breakpoint file
" for the file currently selected
function! s:breakpointFilename()
	let l:dirname = expand("%:h")
	let l:filename = expand("%:t")
	return l:dirname . "/.breakpoints_" . l:filename
endfunction


" Places a breakpoint mark. Either at the current line at the number
" defined by the first argument.
" Return 1 if attempting to place outside valid range.
" Return 2 if a breakpoint already exists at that line
" Return 0 if successfully placed
function! breakpoint#place(...)
	let l:lnum = a:0 == 1 ? a:1 : line(".")
	" can't place breakpoint outside file
	if l:lnum > line("$") || l:lnum < 1
		return 1
	endif
	let l:fname = expand("%:p")

	" Make sure that no duplicate breakpoints exists in file
	for [n, _, file] in g:breakpoints
		if n == l:lnum && l:fname == file
			return 2
		endif
	endfor

	execute printf(":sign place %d line=%d name=breakpoint file=%s",
				\ s:counter,
				\ l:lnum,
				\ l:fname)

	let g:breakpoints += [[l:lnum, s:counter, l:fname]]
	let s:counter += 1
	return 0
endfunction

" Remove the breakpoint at the cursors current line
" returns 1 if breakpoint was removed, 0 otherwise
" Takes one optional argument which is a line number, uses the
" current line if no number is given
function! breakpoint#remove(...)
	let l:lnum = a:0 == 1 ? a:1 : line(".")
	" can't place breakpoint outside file
	if l:lnum > line("$") || l:lnum < 1
		return 1
	endif
	let l:fname = expand("%:p")

	" this is so we can delete the breakpoint from the list
	let l:index = 0

	for [n, cpos, file] in g:breakpoints
		let [n, cpos, file] = g:breakpoints[l:index]
		if l:lnum == n && l:fname == file
			execute printf(":sign unplace %d file=%s",
						\ cpos,
						\ l:fname)
			unlet g:breakpoints[l:index]
			"break
			return 1
		endif
		let l:index += 1
	endfor
	return 0
endfunction

function! breakpoint#toggle(...)
	if a:0 == 1
		if !breakpoint#remove(a:1)
			call breakpoint#place(a:1)
		endif
	else
		if !breakpoint#remove()
			call breakpoint#place()
		endif
	endif
endfunction

" saves to file if breakpoints are set
" deletes the file if no breakpoints exist
"
" Errors if trying to save breakpoints where it isn't allowed to.
" This is good.
function! breakpoint#save()
	let l:fname = expand("%:p")
	let l:lines = []
	for [line, _, file] in g:breakpoints
		if l:fname == file
			let l:lines += [printf("break %s:%d", l:fname, line)]
		endif
	endfor

	if (empty(l:lines))
		call delete(s:breakpointFilename())
	else
		call writefile(l:lines, s:breakpointFilename())
		echom "Saved Breakpoints"
	endif

	return 0
endfunction

" returns a -1 if file can't be read
" otherwise return number of breakpoints loaded
function! breakpoint#load()
	let l:fname = s:breakpointFilename()
	if !filereadable(l:fname)
		return -1
	endif

	let l:count = 0
	for breakinfo in readfile(s:breakpointFilename())
		let l:line = split(breakinfo, ":")[1]
		call breakpoint#place(l:line)
		let l:count += 1
	endfor
	return l:count
endfunction

" TODO is this the best autocmd patters
augroup breakpoint
	autocmd!
	autocmd BufNewFile,BufRead * :call breakpoint#load()
	autocmd BufWritePre,FileWritePre * :call breakpoint#save()
augroup END

command! -count -bar BreakpointPlace
			\ call breakpoint#place(<count> ? <count> : line('.'))
command! -count -bar BreakpointRemove
			\ call breakpoint#remove(<count> ? <count> : line('.'))
command! -count -bar BreakpointToggle
			\ call breakpoint#toggle(<count> ? <count> : line('.'))
command! -bar BreakpointSave call breakpoint#save()
command! -bar BreakpointLoad call breakpoint#load()

nnoremap <leader>a :BreakpointToggle<cr>
