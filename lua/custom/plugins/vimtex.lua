return {
  'lervag/vimtex',
  config = function()
    -- PDF viewer configuration
    vim.g.vimtex_view_method = 'zathura'
    
    -- Auto-compilation settings
    vim.g.vimtex_compiler_latexmk = {
      continuous = 1,  -- Enable continuous compilation
      callback = 1,    -- Enable callbacks
    }
    
    -- Forward search configuration  
    vim.g.vimtex_view_forward_search_on_start = 0
    
    -- Disable some features for better performance
    vim.g.vimtex_compiler_progname = 'nvr'
    vim.g.vimtex_view_automatic = 1
  end,
  ft = 'tex',
}
