-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.termguicolors = true
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.encoding = 'utf-8'
vim.opt.conceallevel = 2
vim.o.mouse= ''
--
-- redirct messages to netify
local notify = require("notify")

-- Set nvim-notify as the default notification handler
vim.notify = notify

require("notify").setup({
    stages = "fade", -- Animation style
    timeout = 3000,  -- Time for notification to disappear (in ms)
    background_colour = "#000000",
})

-- Redirect all Neovim messages to nvim-notify
local function notify_output()
    local messages = vim.api.nvim_exec2("messages", { output = true }).output
    if messages ~= "" then
        notify(messages, "info", { title = "Neovim Message" })
    end
end

-- Hook to display messages after every command
vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = notify_output,
})
--
-- Enable wildmenu for better command-line autocompletion
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full' -- Completes the longest match first and then shows full matches

-- Folding settings for Markdown
vim.cmd [[
  autocmd FileType markdown setlocal foldmethod=expr
  autocmd FileType markdown setlocal foldexpr=MarkdownFoldExpr()
]]

-- Insert Date command
vim.api.nvim_create_user_command('InsertDate', function()
  vim.api.nvim_feedkeys(vim.fn.strftime("%b %d, %y"), 'n', true)
end, {})

-- Airline settings for the status line
vim.g.airline_powerline_fonts = 1
vim.g.airline_left_sep = ''
vim.g.airline_left_alt_sep = ''
vim.g.airline_right_sep = ''
vim.g.airline_right_alt_sep = ''
vim.g.airline_symbols = {
    branch = '',
    readonly = '',
    linenr = ''
}

-- Key Mappings
vim.api.nvim_set_keymap('n', '<leader>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-f>', ':NERDTreeFocus<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTree<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-t>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':call CocActionAsync("jumpDefinition")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F8>', ':TagbarToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })

-- Telescope Key Mappings
local telescope = require('telescope.builtin')

-- Switch between buffers with Telescope
vim.keymap.set('n', '<leader>bb', telescope.buffers, { desc = 'Switch between buffers' })

-- Navigate between buffers
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', ':bprev<CR>', { desc = 'Previous buffer' })

-- Close the current buffer
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close current buffer' })

-- Confirm selection
vim.keymap.set('n', '<C-r>', telescope.find_files, { desc = 'Confirm selection' })

-- Save all buffers
vim.keymap.set('n', '<leader>wa', ':wa<CR>', { desc = 'Save all buffers' })

-- Enable Markdown-specific fold expression
function MarkdownFoldExpr()
  local thisline = vim.fn.getline(vim.fn.line('.'))
  local nextline = vim.fn.getline(vim.fn.line('.') + 1)
  if nextline:match('^##') then
    return '>1'
  else
    return '='
  end
end

-- Calling Lua file to load plugins
require('plugins')

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- Using vsnip or other snippet engines
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'cmdline' },  -- Enable command-line completion
  },
}

-- Setup cmdline completions
cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' },  -- Command-line completion
    { name = 'path' },     -- Path completion (for file names, etc.)
  }
})

-- For other command-line modes like /search or ?search:
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' },   -- Search buffer contents
    { name = 'path' },     -- Path completion
  }
})

cmp.setup.cmdline('?', {
  sources = {
    { name = 'buffer' },
    { name = 'path' },
  }
})


require("nvim-treesitter.configs").setup({
  ensure_installed = { "markdown", "markdown_inline" },
  highlight = {
    enable = true,
  },
})
