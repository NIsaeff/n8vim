# Neovim C Development Quick Reference

## LSP Features (Always Active in C files)

| Key | Action |
|-----|--------|
| `grd` | Go to definition |
| `grr` | Find references |
| `gri` | Go to implementation |
| `grD` | Go to declaration (header) |
| `grt` | Go to type definition |
| `grn` | Rename symbol |
| `gra` | Code actions |
| `K` | Hover documentation |
| `<leader>f` | Format code |

## Debugging (DAP + GDB)

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue/Start debug |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle debug UI |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate session |
| `<leader>dl` | Run last config |

## Building

| Key | Action |
|-----|--------|
| `<leader>br` | Run build task (menu) |
| `<leader>bb` | Quick make build |
| `<leader>bt` | Toggle task panel |
| `<leader>bq` | Quick action |

## Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle terminal |
| `<leader>th` | Horizontal split terminal |
| `<leader>tv` | Vertical split terminal |
| `<leader>tf` | Floating terminal |

## Man Pages (C/C++ only)

| Key | Action |
|-----|--------|
| `K` | LSP hover or man page |
| `<leader>m` | Force man page |
| `<leader>2` | Man section 2 (syscalls) |
| `<leader>3` | Man section 3 (C library) |

## Typical Workflow

1. **Open file**: `nvim main.c`
2. **Code** with LSP auto-complete
3. **Build**: `<leader>br` → select "make build"
4. **Debug**:
   - Set breakpoint: `<leader>db`
   - Start: `<leader>dc`
   - Step through: `<leader>do`, `<leader>di`
   - View UI: `<leader>du`
5. **Look up docs**: cursor on function, press `<leader>3`

## Tips

- Use `:checkhealth` to verify LSP and DAP setup
- For best LSP results, generate `compile_commands.json`:
  - `bear -- make` (if using make)
  - `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .` (if using cmake)
- GDB must support DAP (GDB 14.1+)
- Install `bear` for compile_commands generation: `sudo pacman -S bear`
