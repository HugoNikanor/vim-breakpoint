" TODO expand this to work on multiple files better
" :sign place {id} line={lnum} name={name} file={fname}
"
" <plug> ?

highlight Breakpoint ctermfg=Red

sign define breakpoint text=* texthl=Breakpoint

" This is so my sign numbering (hopefully) doesn't collide
" with some other plugin
let s:counterOffset = 3000
let g:counter = s:counterOffset + 1
let g:breakpoints = []

" retuns a string containing the name of the breakpoint file
" for the file currently selected
function! s:breakpointFilename()
	let l:dirname = expand("%:h")
	let l:filename = expand("%:t")
	return l:dirname . "/.breakpoints_" . l:filename
endfunction


" TODO check that lnum shouldn't be larger than the amount of lines in the
" file
" place([line]):
" adds breakpoint at `line' or at current line
function! breakpoint#place(...)
	let l:lnum = a:0 == 1 ? a:1 : line(".")
	" can't place breakpoint outside file
	if l:lnum > line("$") || l:lnum < 1
		return
	endif
	let l:fname = expand("%:p")

	" Make sure that no duplicate breakpoints exists in file
	for [n, _, file] in g:breakpoints
		if n == l:lnum && l:fname == file
			return
		endif
	endfor

	execute printf(":sign place %d line=%d name=breakpoint file=%s",
				\ g:counter,
				\ l:lnum,
				\ l:fname)

	let g:breakpoints += [[l:lnum, g:counter, l:fname]]
	let g:counter += 1
endfunction

" Remove the breakpoint at the cursors current line
" returns 1 if breakpoint was removed, 0 otherwise
function! breakpoint#remove()
	let l:lnum = line(".")
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

function! breakpoint#toggle()
	if !breakpoint#remove()
		call breakpoint#place()
	endif
endfunction

" saves to file if breakpoints are set
" deletes the file if no breakpoints exist
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
	endif
endfunction

" This just dosn't do anything if there is no breakpoint file
function! breakpoint#load()
	for breakinfo in readfile(s:breakpointFilename())
		let l:line = split(breakinfo, ":")[1]
		call breakpoint#place(l:line)
	endfor
endfunction

" TODO auto group?
" This also doesn't seem to work
autocmd FileReadPost * call breakpoint#load()
autocmd FileWritePre * call Breakpoint#save()

"nnoremap <leader>e :call breakpoint#place()<cr>
"nnoremap <leader>b :call breakpoint#remove()<cr>
nnoremap <leader>a :call breakpoint#toggle()<cr>
