-- Set <space> as the leader key
--- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = ' '

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
vim.o.signcolumn = 'no'
vim.g.tabline = 0
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

-- [[ NETWR ]]
vim.keymap.set('n', '<Leader>cd', ":lcd %:p:h<CR>", { silent = true })

-- [[ Plugins ]]

-- [[ Toggles ]]
vim.keymap.set({ 'n' }, '<Leader>tp', ':set paste! paste?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tw', ':set wrap! wrap?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tsb', ':set scrollbind!<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tss', ':set spell! spell?<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>tci', ':set ic! ic?<CR>', { silent = true })

-- [[ Language Stuff ]]

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
