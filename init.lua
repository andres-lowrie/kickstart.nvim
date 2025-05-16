-- Set <space> as the leader key
--- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration
  'gcmt/taboo.vim',

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-abolish',
  'junegunn/gv.vim',

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true
  },


  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  --Vinegar: https://github.com/tpope/vim-vinegar
  'tpope/vim-vinegar',

  -- Surround: https://github.com/tpope/vim-surround
  'tpope/vim-surround',

  -- Signature:  https://github.com/kshenoy/vim-signature
  'kshenoy/vim-signature',

  -- there are a bunch of plugins that want to use this so
  { 'nvim-tree/nvim-web-devicons' },
  {
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require('notify')
    end
  },

  -- Goyo: https://github.com/junegunn/goyo.vim
  {
    'junegunn/goyo.vim',
    config = function()
      vim.api.nvim_create_autocmd("User", {
        callback = function()
          require('lualine').hide({})
        end,
        pattern = "GoyoEnter"
      })
      vim.api.nvim_create_autocmd("User", {
        callback = function()
          require('lualine').hide({ unhide = true })
        end,
        pattern = "GoyoLeave"
      })
    end
  },

  {
    'pwntester/octo.nvim',
    config = function()
      require('octo').setup({
        mappings = {
          pull_request = {
            checkout_pr = { lhs = "<space>po", desc = "Checkout PR" }
          },
        },
        suppress_missing_scope = {
          projects_v2 = true,
        },
      })

      local proc = io.popen('git branch --show-current')
      local current_branch = proc:read('*all')
      proc:close()

      --- vim.api.nvim_set_keymap('n', '<leader>g/',
      ---   ':Octo search repo:<some-repo> is:pr is:open draft:false<cr>',
      ---   { noremap = true, silent = true })
    end
  },

  {
    'tpope/vim-dotenv',
    config = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        pattern = { "*" },
        callback = function()
          vim.api.nvim_exec2([[
          if exists(':Dotenv') | exe ':Dotenv! ~/.dadbod.env' | endif
          ]], {})
        end
      })
    end
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod',                     lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    config = function()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dbout" },
        command = "setlocal nofoldenable"
      })
    end,
    init = function()
      -- DBUI configuration
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_save_location = '~/Queries'
      vim.g.db_ui_use_nvim_notify = 1
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.keymap.set('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', { desc = "[M]arkdown [P]review" })
    end
  },

  -- Co-Pilot
  -- I put this before the completion stuff since I'm pretty sure (although I
  -- haven't dug deep) that those plugins need to be loaded after this
  {
    'github/copilot.vim',
    init = function()
      vim.keymap.set('i', '<C-F>', '<Plug>(copilot-accept-word)')
      vim.keymap.set('i', '<C-]>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      vim.g.copilot_no_tab_map = true
    end
  },

  -- Scala
  -- Using metals instead of nvim-lspconfig since this plugin implements more features
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ft = { "scala", "sbt", "java" },
    opts = function()
      local metals_config = require("metals").bare_config()
      metals_config.on_attach = function(client, bufnr)
        -- your on_attach function
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = self.ft,
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end
  },

  -- Lexima: https://github.com/cohama/lexima.vim
  -- use in lieu of auto-pairs
  'cohama/lexima.vim',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context'
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',       opts = {} },
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>hn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>hhp', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    -- Theme
    'EdenEast/nightfox.nvim',
    priority = 1000,
    config = function()
      local commentcolor = '#33aaaa' -- cyan
      local options = {}
      local palettes = {
        nightfox = {
          comment = commentcolor,
        },
        nordfox = {
          comment = commentcolor,
        },
        dawnfox = {
          comment = commentcolor,
        },
        dayfox = {
          comment = commentcolor,
          bg1 = "#ffffff",
        },
      }

      require('nightfox').setup({
        palettes = palettes,
        options = options,
      })
      vim.cmd.colorscheme 'nordfox'

      -- hacks for octo plugin
      vim.cmd('hi OctoEditable guibg=None')
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'nord',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = 'ibl',
    opts = {
      indent = {
        char = '┊',
      }
    },
  },

  -- comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    config = function()
      local opts = {
        toggler = {
          line = 'cll'
        },
        opleader = {
          line = 'cl'
        },
      }
      require("Comment").setup(opts)

      local ft = require("Comment.ft")
      ft.lua = "---%s"
      ft.sqlx = "/*%s*/"
    end
  },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim',          branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- use telescope for vim.ui.select
  { 'nvim-telescope/telescope-ui-select.nvim' },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    't9md/vim-choosewin',
    config = function()
      vim.g.choosewin_overlay_enable = 1
      vim.keymap.set({ 'n' }, '<Leader>ww', '<Plug>(choosewin)')
    end
  },

  {
    'phaazon/hop.nvim',
    config = function()
      require('hop').setup()
      vim.keymap.set({ 'n' }, '<Leader>jw',
        "<cmd>lua require'hop'.hint_char1({ direction = nil, current_line_only = false })<CR>")
    end
  },

  -- Wiki
  {
    'vimwiki/vimwiki',
    init = function()
      local api = vim.api
      local opts = { noremap = true, silent = true }

      -- diable html bindings
      api.nvim_exec2([[
        let g:vimwiki_key_mappings =
          \{
          \ 'html': 0,
          \}
        ]]
      , {})

      -- use markdown but only in the vimwiki dir
      api.nvim_exec2([[
          let g:vimwiki_list = [{  'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md' }]
          let g:vimwiki_table_auto_fmt = 0
        ]]
      , {})

      vim.g.vimwiki_global_ext = 0


      api.nvim_set_keymap('n', '<leader>w<BS>', '<Plug>VimwikiIndex', opts)
      api.nvim_set_keymap('n', '<leader>wx', '<Plug>VimwikiDeleteFile', opts)
      api.nvim_set_keymap('n', '<leader>w<TAB>', '<Plug>VimwikiUISelect', opts)
    end
  },

  -- Tabular
  { 'godlygeek/tabular' },


  -- Dealing with windows
  {
    'pogyomo/winresize.nvim',
    config = function()
      local resize = function(win, amt, dir)
        return function()
          require("winresize").resize(win, amt, dir)
        end
      end

      vim.keymap.set({ "n" }, "rh", resize(0, 5, "left"))
      vim.keymap.set({ "n" }, "rj", resize(0, 4, "down"))
      vim.keymap.set({ "n" }, "rk", resize(0, 4, "up"))
      vim.keymap.set({ "n" }, "rl", resize(0, 5, "right"))
    end
  },

  -- In this repo
  require 'kickstart.plugins.autoformat',
  { import = 'custom.plugins' },

  -- My Garbage from outside ths directory that's "published"
  {
    'andres-lowrie/vim-maximizer',
    config = function()
      vim.keymap.set({ 'n' }, '<Leader>wm', ':MaximizerToggle<CR>')
    end
  },
  {
    'andres-lowrie/nvim-search-internet',
    config = function()
      vim.keymap.set({ 'n' }, '<Leader>si', require('search-internet').selection, { desc = "[S]earch [I]nternet" })
      vim.keymap.set({ 'n' }, '<Leader>sw', require('search-internet').word_under_cursor,
        { desc = "[S]earch Internet for [W]ord under cursor" })
    end
  },

  -- Hot trash garbage that's local and not published
}, {})

-- global functions for deving and ihm specific stuff
require 'for_deving'
require 'lint_and_format'
require 'web_shortcuts'


-- [[ Setting options ]]
-- See `:help vim.o`
-- [[ Base/Essentials ]]
vim.api.nvim_create_augroup("mine", { clear = false })

vim.go.ignorecase = true
vim.go.incsearch = true
vim.go.smartcase = true
vim.go.spelllang = 'en_us'
vim.o.autoindent = true
vim.o.breakindent = true
vim.o.completeopt = 'menuone,noselect'
vim.o.hlsearch = false
vim.o.mouse = 'a'
vim.o.number = true
vim.o.relativenumber = true
vim.o.shell = "/bin/bash"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabpagemax = 100
vim.o.termguicolors = true
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.updatetime = 250
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.keymap.set({ 'n' }, 'gqq', 'gww')

-- [[ Indentation ]]
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.wrap = false
vim.o.formatoptions = "croql"

-- [[ Diffing ]]
vim.opt.diffopt:append { "vertical" }

-- [[ Clipboard ]]
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'
vim.keymap.set({ 'n' }, '<Leader>y', '"*y', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>Y', '"*Y', { silent = true })

-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set({ 'i' }, '<C-j>', '(', { silent = true })
vim.keymap.set({ 'i' }, '<C-k>', '{', { silent = true })
vim.keymap.set({ 'i' }, '<C-l>', '[', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


-- [[ Arrow Keys ]]
-- @todo need to figure out how to change these depending on what I"m doing or
--  which type of file I'm dealing with, for example when in diff mode or
--  vim-fugitive then I want these
--  a minor mode would be pretty cool here
vim.keymap.set('n', '<Up>', "[c", { silent = true })
vim.keymap.set('n', '<Down>', "]c", { silent = true })
vim.keymap.set('n', '<Left>', ":diffget //2<CR>", { silent = true })
vim.keymap.set('n', '<Right>', ":diffget //3<CR>", { silent = true })


-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Windows and Project ]]
-- Spliting
vim.keymap.set('n', '<Leader>w-', "<C-w>s", { silent = true })
vim.keymap.set('n', '<Leader>w/', "<C-w>v", { silent = true })
vim.keymap.set('n', '<Leader>wh', "<C-w>h", { silent = true })
vim.keymap.set('n', '<Leader>wj', "<C-w>j", { silent = true })
vim.keymap.set('n', '<Leader>wk', "<C-w>k", { silent = true })
vim.keymap.set('n', '<Leader>wl', "<C-w>l", { silent = true })
vim.keymap.set('n', '<Leader>w=', "<C-w>=", { silent = true })
-- Moving
vim.keymap.set('n', '<Leader>wL', "<C-w>L", { silent = true })
vim.keymap.set('n', '<Leader>wH', "<C-w>H", { silent = true })
vim.keymap.set('n', '<Leader>wJ', "<C-w>J", { silent = true })
vim.keymap.set('n', '<Leader>wK', "<C-w>K", { silent = true })
-- Writing/Reading
vim.keymap.set('n', '<Leader>wd', ":close<CR>", { silent = true })
vim.keymap.set('n', '<Leader>wo', "<C-w>o", { silent = true })
vim.keymap.set('n', '<Leader>fs', ":w<CR>", { silent = true })
vim.keymap.set('n', '<Leader>fa', ":wa<CR>", { silent = true })

-- [[ Buffers ]]
-- Last Buffer
vim.keymap.set('n', '<Leader><Tab>', ":e#<CR>", { silent = true })
-- Delete Buffer
vim.keymap.set('n', '<Leader>bd', ":bdelete<CR>", { silent = true })

-- [[ Insert Mode ]]
vim.keymap.set('i', '<C-a>', "<C-o>^", { silent = true })
vim.keymap.set('i', '<C-e>', "<C-o>$", { silent = true })
vim.keymap.set('i', '<C-h>', "<BS>", { silent = true })

-- [[ Command Mode ]]
vim.keymap.set('c', '<C-a>', "<Home>", { silent = true })
vim.keymap.set('c', '<C-e>', "<End>", { silent = true })
vim.keymap.set('c', '<C-p>', "<Up>", { silent = true })
vim.keymap.set('c', '<C-n>', "<Down>", { silent = true })
vim.keymap.set('c', '<M-b>', "<Left>", { silent = true })
vim.keymap.set('c', '<M-e>', "<Right>", { silent = true })

-- [[ File Info ]]
vim.keymap.set('n', '<Leader>sc', ":noh<CR>", { silent = true })
vim.keymap.set('n', '<BS>', ':echo expand("%:p")<CR>', { silent = true })
vim.keymap.set('n', '<Leader><BS>', ':let @+=expand("%:p")<CR>', { silent = true })
vim.keymap.set('n', 'gF', '<c-w>vgF', { silent = true })

-- [[ NETWR ]]
vim.keymap.set('n', '<Leader>cd', ":lcd %:p:h<CR>", { silent = true })

-- [[ Plugins ]]
-- fugitive (git)
vim.keymap.set('n', '<Leader>gs', ':Git<CR>', { desc = "[G]it [S]tatus" })
vim.keymap.set('n', '<Leader>gd', ':Gdiffsplit!<CR>', { desc = "[G]it [D]iff" })
vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', { desc = "[G]it [B]lame" })
vim.keymap.set('n', '<Leader>ge', ':Gedit<CR>', { desc = "[G]it [E]dit. Or return to regular edit" })
vim.keymap.set('n', '<Leader>gh', ':0Gclog<CR>', { desc = "[G]it [H]istory current file" })
vim.keymap.set('n', '<Leader>gp', ':Git -c push.default=current push<CR>', { desc = "[G]it [P]ush" })
vim.keymap.set('n', '<Leader>gpf', ':Git -c push.default=current push --force<CR>',
  { desc = "[G]it [P]ush [F]orce" })
vim.keymap.set('n', '<Leader>gr', ':Git rebase -i HEAD~2', { desc = "[G]it [R]ebase" })
vim.keymap.set('n', '<Leader>gc', ':Git rebase --continue<CR>', { desc = "[R]ebase [C]ontinue" })
vim.keymap.set('n', '<Leader>gu', ':Git checkout %', { desc = "[G]it [U]ndo changes to this file" })
vim.keymap.set('n', '<Leader>gg', function()
  local filename = vim.fn.expand('%:t')
  if string.match(filename, 'fugitiveblame') then
    vim.api.nvim_cmd({ cmd = 'GBrowse', args = { '<cfile>' } }, {})
  else
    vim.api.nvim_cmd({ cmd = 'GBrowse' }, {})
  end
end, { desc = "[G]it [O]pen browser" })
vim.keymap.set('n', '<Leader>gl', ':GV!<CR>', { desc = "[G]it [L]og current file" })
vim.keymap.set('n', '<Leader>gll', ':GV<CR>', { desc = "[G]it [L]og [L]ong or all files" })
vim.keymap.set('n', '<Leader>glr', ':GV?<CR>', { desc = "[G]it [L]og [R]evisions for current file" })

-- goyo
vim.g.goyo_width = 140
vim.keymap.set('n', '<Leader>tz', ':Goyo<CR>', { desc = '[T]oggle [G]oyo' })

-- [[ Toggles ]]
vim.keymap.set({ 'n' }, '<Leader>tp', ':set paste! paste?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tw', ':set wrap! wrap?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tsb', ':set scrollbind!<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tss', ':set spell! spell?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tci', ':set ic! ic?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tcc', ':TSContextToggle<CR>', { silent = true })

-- [[ Tabs ]]
vim.keymap.set({ 'n' }, 'T', ':tabnew %<CR>', { silent = true })

-- [[ Macros ]]
vim.keymap.set({ 'n' }, '<Leader>x', function()
  vim.api.nvim_command('!rm -f scratch')
  vim.api.nvim_command(':e scratch')
end, { silent = true, desc = "[X] scratch buffer" })

-- [[ Language Stuff ]]

-- Bats
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufReadPost" }, {
  group = "mine",
  pattern = "*.bats",
  command = "set syntax=sh"
})

-- SQL and sql-likes (not sqlx, have specific plugin for that)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufReadPost" }, {
  group = "mine",
  pattern = "*.hql",
  command = "set syntax=sql"
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-f>'] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist
      },
    },
  },
  extension = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({})
    }
  }
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
require('telescope').load_extension("ui-select")

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>bb', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  --
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>ff', function()
    require('telescope.builtin').find_files({ cwd = require('telescope.utils').buffer_dir() })
  end,
  { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c',
    'cpp',
    'go',
    'lua',
    'python',
    'rust',
    'tsx',
    'typescript',
    'javascript',
    'vimdoc',
    'vim',
    'sql',
    'http',
    'json'
  },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic
vim.diagnostic.config({ virtual_text = false, underline = false })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gD', '<c-w>v<cmd>lua vim.lsp.buf.definition()<CR>', '[G]oto [D]efinition in a new vsplit')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ss', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  clangd = {},
  gopls = {},
  pyright = {},
  rust_analyzer = {},
  tsserver = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  marksman = {}
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Golang
-- from https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
-- note sure if there is a better hook or place to put this so ... at the end it goes
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
