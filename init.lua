-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
--   vim.opt.clipboard = 'unnamedplus'
-- end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true
vim.opt.history = 10000

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'auto'

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 600

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = '⏎' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.exrc = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.linebreak = false
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.updatetime = 500
vim.opt.colorcolumn = '81'

require 'custom.keymaps'
require 'custom.commands'

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  require 'custom.plugins.which-key', -- Useful plugin to show you pending keybinds.
  require 'custom.plugins.telescope',
  require 'custom.plugins.lsp',
  require 'custom.plugins.conform', -- Autoformat
  require 'custom.plugins.cmp', -- Autocompletion
  require 'custom.plugins.selenized',
  require 'custom.plugins.mini', -- Collection of various small independent plugins/modules
  require 'custom.plugins.treesitter', -- Highlight, edit, and navigate code
  require 'custom.plugins.a',
  require 'custom.plugins.oil',
  require 'custom.plugins.rainbow-delimiters',
  require 'custom.plugins.gp',

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'numToStr/Comment.nvim',
    opts = {
      padding = false,
    },
  },
  { 'tpope/vim-obsession' },
  { 'tpope/vim-speeddating' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-sleuth' },
  { 'tpope/vim-repeat' },
  {
    'bkad/CamelCaseMotion',
    init = function()
      vim.g.camelcasemotion_key = ','
    end,
  },
  { 'ngg/vim-gn' },
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('easy-dotnet').setup {
        get_sdk_path = function()
          return '/usr/local/share/dotnet/sdk/8.0.402'
        end,
        test_runner = {
          viewmode = 'float',
        },
      }
    end,
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'Issafalcon/neotest-dotnet',
      'thenbe/neotest-playwright',
      {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false, -- This plugin is already lazy
      },
    },
    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        adapters = {
          require 'neotest-dotnet' {
            dap = {
              -- Extra arguments for nvim-dap configuration
              -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
              args = { justMyCode = false },
              -- Enter the name of your dap adapter, the default value is netcoredbg
              adapter_name = 'netcoredbg',
            },
            -- Let the test-discovery know about your custom attributes (otherwise tests will not be picked up)
            -- Note: Only custom attributes for non-parameterized tests should be added here. See the support note about parameterized tests
            custom_attributes = {
              -- xunit = { "MyCustomFactAttribute" },
              -- nunit = { "MyCustomTestAttribute" },
              -- mstest = { "MyCustomTestMethodAttribute" }
            },
            -- Provide any additional "dotnet test" CLI commands here. These will be applied to ALL test runs performed via neotest. These need to be a table of strings, ideally with one key-value pair per item.
            dotnet_additional_args = {
              '--verbosity detailed --no-restore --no-build',
            },
            -- Tell neotest-dotnet to use either solution (requires .sln file) or project (requires .csproj or .fsproj file) as project root
            -- Note: If neovim is opened from the solution root, using the 'project' setting may sometimes find all nested projects, however,
            --       to locate all test projects in the solution more reliably (if a .sln file is present) then 'solution' is better.
            discovery_root = 'solution', -- Default
          },
          require('neotest-playwright').adapter {
            options = {
              persist_project_selection = true,
              enable_dynamic_test_discovery = true,
            },
          },
        },
        benchmark = {
          enabled = true,
        },
        consumers = {
          playwright = require('neotest-playwright.consumers').consumers,
        },
        default_strategy = 'integrated',
        diagnostic = {
          enabled = true,
          severity = 1,
        },
        discovery = {
          concurrent = 0,
          enabled = true,
        },
        floating = {
          border = 'rounded',
          max_height = 0.6,
          max_width = 0.6,
          options = {},
        },
        highlights = {
          adapter_name = 'NeotestAdapterName',
          border = 'NeotestBorder',
          dir = 'NeotestDir',
          expand_marker = 'NeotestExpandMarker',
          failed = 'NeotestFailed',
          file = 'NeotestFile',
          focused = 'NeotestFocused',
          indent = 'NeotestIndent',
          marked = 'NeotestMarked',
          namespace = 'NeotestNamespace',
          passed = 'NeotestPassed',
          running = 'NeotestRunning',
          select_win = 'NeotestWinSelect',
          skipped = 'NeotestSkipped',
          target = 'NeotestTarget',
          test = 'NeotestTest',
          unknown = 'NeotestUnknown',
          watching = 'NeotestWatching',
        },
        icons = {
          child_indent = '│',
          child_prefix = '├',
          collapsed = '─',
          expanded = '╮',
          failed = '',
          final_child_indent = ' ',
          final_child_prefix = '╰',
          non_collapsible = '─',
          passed = '',
          running = '',
          running_animated = { '/', '|', '\\', '-', '/', '|', '\\', '-' },
          skipped = '',
          unknown = '',
          watching = '',
        },
        jump = {
          enabled = true,
        },
        log_level = 3,
        output = {
          enabled = true,
          open_on_run = 'short',
        },
        output_panel = {
          enabled = true,
          open = 'botright split | resize 15',
        },
        projects = {},
        quickfix = {
          enabled = true,
          open = false,
        },
        run = {
          enabled = true,
        },
        running = {
          concurrent = true,
        },
        state = {
          enabled = true,
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = false,
        },
        strategies = {
          integrated = {
            height = 40,
            width = 120,
          },
        },
        summary = {
          animated = true,
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = 'a',
            clear_marked = 'M',
            clear_target = 'T',
            debug = 'd',
            debug_marked = 'D',
            expand = { '<CR>', '<2-LeftMouse>' },
            expand_all = 'e',
            jumpto = 'i',
            mark = 'm',
            next_failed = 'J',
            output = 'o',
            prev_failed = 'K',
            run = 'r',
            run_marked = 'R',
            short = 'O',
            stop = 'u',
            target = 't',
            watch = 'w',
          },
          open = 'botright vsplit | vertical resize 50',
        },
        watch = {
          enabled = true,
        },
      }
      vim.keymap.set('n', '<localleader>tfr', function()
        neotest.run.run(vim.fn.expand '%')
      end, { desc = '[T]est ?[fr]?', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>tr', function()
        neotest.run.run()
        neotest.summary.open()
      end, { desc = '[T]est [r]un and open summary', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>ts', function()
        neotest.run.stop()
      end, { desc = '[T]est [s]top', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>to', function()
        neotest.output.open { last_run = true, enter = true }
      end, { desc = '[T]est [o]utput open', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>tt', function()
        neotest.summary.toggle()
      end, { desc = '[T]est [t]oggle summary', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>tn', neotest.jump.next, { desc = '[T]est [n]ext', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>tp', neotest.jump.prev, { desc = '[T]est [p]revious', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<localleader>tl', function()
        neotest.run.run_last { enter = true }
        neotest.output.open { last_run = true, enter = true }
      end, { desc = '[T]est rerun [l]ast', noremap = true, silent = true, nowait = true })
      vim.keymap.set('n', '<leader>ta', function()
        require('neotest').playwright.attachment()
      end, { desc = 'Launch test attachment' })
    end,
  },

  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
