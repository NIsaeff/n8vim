# Tmux + Neovim Navigation Test

## Setup Complete! 🎉

Your vim-tmux-navigator is now configured. Here are the key bindings:

### Navigation Keys:
- **Ctrl+h** - Move left (vim split or tmux pane)
- **Ctrl+j** - Move down (vim split or tmux pane)  
- **Ctrl+k** - Move up (vim split or tmux pane)
- **Ctrl+l** - Move right (vim split or tmux pane)
- **Ctrl+\\** - Move to previous pane/split

### Test Instructions:

1. **In tmux**: Create some panes with `Ctrl+a s` (horizontal) or `Ctrl+a v` (vertical)
2. **Open this file in nvim**: `nvim ~/.config/nvim/test-navigation.md`  
3. **Create vim splits**: `:vsplit` or `:split` in nvim
4. **Test navigation**: Use Ctrl+h/j/k/l to move between vim splits AND tmux panes seamlessly!

### What was configured:

#### Neovim (init.lua):
```lua
{
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown', 
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
  },
  keys = {
    { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
    { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
    { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
    { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
    { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
  },
},
```

#### Tmux (tmux.conf):
- Smart detection of vim processes
- Seamless navigation between tmux panes and vim splits
- Support for previous pane navigation

### Troubleshooting:

If navigation doesn't work:
1. Restart tmux: `tmux source-file ~/.tmux.conf`
2. Restart nvim and run `:Lazy reload vim-tmux-navigator`
3. Check you're using the correct prefix: `Ctrl+a` (not `Ctrl+b`)

---
*Delete this file when testing is complete*