return { { 'nvim-mini/mini.pairs', version = '*' },
  { 'nvim-tree/nvim-tree.lua', version = '*',
    config = function()
      require('nvim-tree').setup {
        filters = { dotfiles = true },
        renderer = { group_empty = true, indent_width = 1 },
      }
      vim.keymap.set('n', '<C-n>', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
      vim.keymap.set('n', '<leader>E', '<cmd>NvimTreeFindFile<CR>', { desc = 'Reveal file in tree' })
    end },
  { 'nvim-tree/nvim-web-devicons', version = '*' } }

