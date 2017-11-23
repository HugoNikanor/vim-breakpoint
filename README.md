Vim Breakpoint
==============
Vim breakpoint is a plugin for easily placing breakpoints from inside Vim.

It saves and reads breakpoints from `$FILEPATH/.breakpoints_$FILENAME`.

Currently it only supports GDB style breakpoints, but this could easily be
extended if I could be bothered.

Currently doesn't delete breakpoint even if line is deleted. This is
however not a large problem, since it is still apparent where the
breakpoints are.

	  1 #include <stdio.h>
	  2 #include <string.h>
	  3 
	  4 int main() {
	  5     printf("%i\n", strcmp("Hello", "Hello"));
	* 6     printf("%i\n", strcmp("hello", "Hello"));
	  7     printf("%i\n", strcmp("Nothing", "Hello"));
	  8 }
*An "image" of vim with a breakpoint on line 6*

Installation
------------
Since a few versions back this plugin requires Vim 8.
The old version which still works with Vim 7 is available
under the tag `v7`.

If using [vim-plugged][1] then the following can be put in
your `vimrc` to automatically get the correct version:

	if version >= 800 |Plug 'HugoNikanor/vim-breakpoint'
	else              |Plug 'HugoNikanor/vim-breakpoint', {'tag': 'v7'}

[1]: https://github.com/junegunn/vim-plug

Usage
-----
The breakpoints save to file whenever you save a file with breakpoints
in it, and also automatically loads a breakpoint file if there is any.

For full usage documentation see `:help breakpoint`

The plugin doesn't bind any keys by itself, so that's up to the user.
I would recommend having the following in your vimrc after loading the plugin:

    nmap <leader>a <Plug>BreakpointToggle

### Commands
- `BreakpointPlace [line]`
- `BreakpointRemove [line]`
- `BreakpointToggle [line]`
- `BreakpointSave`
- `BreakpointLoad`


