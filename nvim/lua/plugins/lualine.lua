return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "rose-pine/neovim", "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local theme = require("lualine.themes.rose-pine")
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "inactive" }) do
      if theme[mode] and theme[mode].c then
        theme[mode].c.bg = "none" -- transparent to match the transparent nvim theme
      end
    end

    require("lualine").setup({
      options = {
        theme = theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
