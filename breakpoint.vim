" TODO expand this to work on multiple files better
" :sign place {id} line={lnum} name={name} file={fname}

highlight Breakpoint ctermfg=Red

sign define breakpoint text=* texthl=Breakpoint


" This is so my sign numbering (hopefully) doesn't collide
" with some other plugin
let s:counterOffset = 3000
let g:counter = s:counterOffset + 1
let g:breakpoints = []

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

" TODO possibly merge the two delete functions into one
function! s:removeByCounter(cpos)
	let l:index = 0
	for [_, counter, fname] in g:breakpoints
		if counter == cpos
			execute printf(":sign unplace %d file=%s",
						\ cpos,
						\ l:fname)
			unlet g:breakpoints[l:index]
			break
		endif
		let l:index += 1
	endfor
endfunction

" Remove the breakpoint at the cursors current line
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
			break
		endif
		let l:index += 1
	endfor

	echo l:index

	unlet g:breakpoints[l:index]

endfunction

" retuns a string containing the name of the breakpoint file
" for the file currently selected
function! s:breakpointFilename()
	let l:dirname = expand("%:h")
	let l:filename = expand("%:t")
	return l:dirname . "/.breakpoints_" . l:filename
endfunction

function! breakpoint#save()
	let l:fname = expand("%:p")
	let l:lines = []
	for [line, _, file] in g:breakpoints
		if l:fname == file
			let l:lines += ["break " . l:fname . ":" . line]
		endif
	endfor
	" add "a" as a final argument to append instead of overwrite
	call writefile(l:lines, s:breakpointFilename())
endfunction

function! breakpoint#load()
	"let l:fname = expand("%:p")
	"let l:lines = 
	for breakinfo in readfile(s:breakpointFilename())
		let l:line = split(breakinfo, ":")[1]
		call breakpoint#place(l:line)
	endfor
endfunction

" TODO auto group?
" This also doesn't seem to work
autocmd FileReadPost * call breakpoint#load()
autocmd FileWritePre * call Breakpoint#save()

nnoremap <leader>a :call breakpoint#place()<cr>
nnoremap <leader>b :call breakpoint#remove()<cr>
