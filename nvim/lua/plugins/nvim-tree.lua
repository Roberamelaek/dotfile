return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = { { "nvim-tree/nvim-web-devicons", version = "*" } },
  lazy = false,
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
    { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal file in tree" },
  },
  config = function()
    require("nvim-tree").setup {
      filters = { dotfiles = true },
      renderer = { group_empty = true, indent_width = 1 },
    }
  end,
}