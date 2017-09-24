Vim Breakpoint
==============
Vim breakpoint is a plugin for easily placing breakpoints from inside Vim.

It saves and reads breakpoints from `$FILEPATH/.breakpoints_$FILENAME`.

Currently it only supports GDB style breakpoints, but this could easily be
extended if I could be bothered.

Currently doesn't delete breakpoint even if line is deleted. This is
however not a large problem, since it is still apparent where the
breakpoints are.

Usage
-----
The breakpoints save to file whenever you save a file with breakpoints
in it, and also automatically loads a breakpoint file if there is any.

### Keybinds
- `<leader>a` :: Toggle breakpoint

### Functions
- `breakpoint#place()`
- `breakpoint#remove()`
- `breakpoint#toggle()`
- `breakpoint#save()`
- `breakpoint#load()`


