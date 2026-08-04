return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("bufferline").setup {
      options = {
        mode = "tabs", -- show a tab for each buffer
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        show_buffer_icons = true,
        separator_style = "slant",
        offsets = {
          { filetype = "NvimTree", text = "File Explorer", text_align = "left", separator = true },
        },
      },
    }
  end,
}