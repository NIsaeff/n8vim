-- C/C++ Development Enhancements
-- Adds debugging (DAP), man pages, and build integration

return {
  -- DAP (Debug Adapter Protocol) for visual debugging
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: [C]ontinue' },
      { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
      { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
      { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug: Step [O]ut' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = '[D]ebug: Toggle [R]EPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: Run [L]ast' },
      { '<leader>dt', function() require('dap').terminate() end, desc = '[D]ebug: [T]erminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: Toggle [U]I' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- DAP UI setup
      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      })

      -- Virtual text setup (shows variable values inline)
      require('nvim-dap-virtual-text').setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        virt_text_pos = 'eol',
      })

      -- Auto-open/close DAP UI
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- GDB adapter configuration for C/C++
      dap.adapters.gdb = {
        type = 'executable',
        command = 'gdb',
        args = { '-i', 'dap' },
      }

      -- C/C++ debug configurations
      dap.configurations.c = {
        {
          name = 'Launch',
          type = 'gdb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = 'Launch with arguments',
          type = 'gdb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' ')
          end,
          cwd = '${workspaceFolder}',
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = 'Attach to process',
          type = 'gdb',
          request = 'attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }

      -- Same config for C++
      dap.configurations.cpp = dap.configurations.c
    end,
  },

  -- Build integration with overseer
  {
    'stevearc/overseer.nvim',
    keys = {
      { '<leader>bt', '<cmd>OverseerToggle<cr>', desc = '[B]uild: [T]oggle' },
      { '<leader>br', '<cmd>OverseerRun<cr>', desc = '[B]uild: [R]un task' },
      { '<leader>bb', '<cmd>OverseerBuild<cr>', desc = '[B]uild: [B]uild (make)' },
      { '<leader>bq', '<cmd>OverseerQuickAction<cr>', desc = '[B]uild: [Q]uick action' },
    },
    opts = {
      templates = { 'builtin' },
      strategy = {
        'toggleterm',
        direction = 'horizontal',
        open_on_start = true,
        quit_on_exit = 'never',
      },
      task_list = {
        direction = 'bottom',
        min_height = 10,
        max_height = 15,
        bindings = {
          ['?'] = 'ShowHelp',
          ['g?'] = 'ShowHelp',
          ['<CR>'] = 'RunAction',
          ['<C-e>'] = 'Edit',
          ['o'] = 'Open',
          ['<C-v>'] = 'OpenVsplit',
          ['<C-s>'] = 'OpenSplit',
          ['<C-f>'] = 'OpenFloat',
          ['<C-q>'] = 'OpenQuickFix',
          ['p'] = 'TogglePreview',
          ['<C-l>'] = 'IncreaseDetail',
          ['<C-h>'] = 'DecreaseDetail',
          ['L'] = 'IncreaseAllDetail',
          ['H'] = 'DecreaseAllDetail',
          ['['] = 'DecreaseWidth',
          [']'] = 'IncreaseWidth',
          ['{'] = 'PrevTask',
          ['}'] = 'NextTask',
          ['<C-k>'] = 'ScrollOutputUp',
          ['<C-j>'] = 'ScrollOutputDown',
          ['q'] = 'Close',
        },
      },
    },
    config = function(_, opts)
      local overseer = require('overseer')
      overseer.setup(opts)

      -- Custom make task template
      overseer.register_template({
        name = 'make build',
        builder = function()
          return {
            cmd = { 'make' },
            components = {
              { 'on_output_quickfix', open = true },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'c', 'cpp' },
        },
      })

      -- Custom gcc compile single file
      overseer.register_template({
        name = 'gcc compile current file',
        builder = function()
          local file = vim.fn.expand('%:p')
          local file_noext = vim.fn.expand('%:p:r')
          return {
            cmd = { 'gcc' },
            args = {
              '-g',           -- Debug symbols
              '-Wall',        -- All warnings
              '-Wextra',      -- Extra warnings
              '-std=c11',     -- C11 standard
              file,
              '-o',
              file_noext,
            },
            components = {
              { 'on_output_quickfix', open = true },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'c' },
        },
      })

      -- Custom cmake build
      overseer.register_template({
        name = 'cmake build',
        builder = function()
          return {
            cmd = { 'cmake' },
            args = { '--build', 'build' },
            components = {
              { 'on_output_quickfix', open = true },
              'default',
            },
          }
        end,
        condition = {
          filetype = { 'c', 'cpp' },
        },
      })
    end,
  },

  -- Terminal integration for running builds
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-\\>', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal', mode = { 'n', 't' } },
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = '[T]erminal: [F]loating' },
      { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = '[T]erminal: [H]orizontal' },
      { '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', desc = '[T]erminal: [V]ertical' },
    },
    opts = {
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = 'horizontal',
      close_on_exit = false,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
      },
    },
  },

  -- Enhanced man page integration
  {
    'nvim-tree/nvim-web-devicons', -- Just to ensure icons work
    config = function()
      -- Man page keybindings for C development
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'c', 'cpp' },
        callback = function()
          local opts = { buffer = true, silent = true }
          
          -- Enhanced man page lookup
          vim.keymap.set('n', 'K', function()
            local word = vim.fn.expand('<cword>')
            -- Try LSP hover first
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients > 0 then
              vim.lsp.buf.hover()
            else
              -- Fallback to man page
              vim.cmd('Man ' .. word)
            end
          end, vim.tbl_extend('force', opts, { desc = 'LSP hover or man page' }))
          
          -- Force man page (even if LSP available)
          vim.keymap.set('n', '<leader>m', function()
            local word = vim.fn.expand('<cword>')
            vim.cmd('Man ' .. word)
          end, vim.tbl_extend('force', opts, { desc = 'Open [M]an page' }))
          
          -- Man page for function under cursor (section 3 - C library)
          vim.keymap.set('n', '<leader>3', function()
            local word = vim.fn.expand('<cword>')
            vim.cmd('Man 3 ' .. word)
          end, vim.tbl_extend('force', opts, { desc = 'Man section [3] (C library)' }))
          
          -- Man page for system calls (section 2)
          vim.keymap.set('n', '<leader>2', function()
            local word = vim.fn.expand('<cword>')
            vim.cmd('Man 2 ' .. word)
          end, vim.tbl_extend('force', opts, { desc = 'Man section [2] (syscalls)' }))
          
          -- Build and run current file (F5 like IDEs)
          vim.keymap.set('n', '<F5>', function()
            local filename = vim.fn.expand('%:t:r')  -- Get filename without extension
            vim.cmd('write')  -- Save first
            vim.cmd('vsplit')
            vim.cmd('terminal make run FILE=' .. filename)
            vim.cmd('startinsert')  -- Enter terminal
            vim.cmd('stopinsert')  -- Exit insert mode immediately
            vim.cmd('wincmd p')  -- Return focus to previous window
          end, vim.tbl_extend('force', opts, { desc = 'Build and run current file' }))
          
          -- Build and run in horizontal split
          vim.keymap.set('n', '<leader>rr', function()
            local filename = vim.fn.expand('%:t:r')
            vim.cmd('write')
            vim.cmd('split')
            vim.cmd('terminal make run FILE=' .. filename)
            vim.cmd('stopinsert')  -- Don't enter insert mode in terminal
            vim.cmd('wincmd p')  -- Return focus to previous window
          end, vim.tbl_extend('force', opts, { desc = '[R]un: Build and [R]un' }))
        end,
      })
    end,
  },
}
