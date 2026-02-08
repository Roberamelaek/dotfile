-- =========================================================
-- Bootstrap lazy.nvim
-- =========================================================
--


-- Install Lazy.nvim if it's not already installed
local install_path = vim.fn.stdpath('data')..'/site/pack/lazy/start/lazy.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/folke/lazy.nvim', install_path})
end


-- set conceallevel for markdown/obsidian files
vim.api.nvim_create_autocmd("FileType", {
 pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"  -- conceal while in normal and command mode
  end,
})


-- Configure your plugins using Lazy.nvim
require("lazy").setup({
-- --     
{ 
	"rose-pine/neovim", 
 	name = "rose-pine",
 	config = function()
 		vim.cmd("colorscheme rose-pine-moon")
 	end
},

{
    "github/copilot.vim",
    config = function()
        -- Enable copilot to work with comments and suggestions
        vim.g.copilot_filetypes = {
            ["*"] = true,          -- Enable Copilot for all filetypes
            ["markdown"] = true,   -- Enable Copilot for Markdown
            ["gitcommit"] = true,  -- Enable Copilot for Git commit messages
        }

        -- Map `<C-e>` to accept Copilot suggestions
        vim.api.nvim_set_keymap(
            "i",
            "<C-e>",
            'copilot#Accept("<CR>")',
            { silent = true, expr = true }
        )

        -- Suggest Copilot inline hints
        vim.g.copilot_no_tab_map = true -- Use custom keymaps instead of `<Tab>`
    end,
},



-- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
{
    'numToStr/Comment.nvim',
    opts = {
        padding = true, -- Add a space b/w comment and line
        -- add any options here
    }
},

  -- Plugins configuration
  {
    "hrsh7th/nvim-cmp", -- Autocompletion plugin
    dependencies = {
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-path", -- Path completions
      "hrsh7th/cmp-cmdline", -- Cmdline completions
      "L3MON4D3/LuaSnip", -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions for nvim-cmp
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Enable nvim-cmp completion
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For luasnip users
          end,
        },
        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-u>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },  -- Snippets from luasnip
          { name = 'buffer' },  -- Buffer completions
          { name = 'path' },  -- Path completions
        }),
      })

      -- Set up cmp for command line mode
      cmp.setup.cmdline(':', {
        sources = {
          { name = 'cmdline' },
        },
      })

      -- Set up cmp for insert mode
      cmp.setup.cmdline('/', {
        sources = {
          { name = 'buffer' },
        },
      })
    end,
  },
----
---
{
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
},
---

--------------------------------------
----------------------------------------
  {
    "epwalsh/obsidian.nvim",
    config = function()
      require("obsidian").setup({
          version = "*",
          lazy = true,
          ft = "markdown",
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },

        workspaces = {
          {
             name = "Self",
            path = "~/Dropbox/2025",
          },
        },
        templates = {
          subdir = "Template",
        },
        completion = {
          nvim_cmp = true,
          min_chars = 1,
        },
        log_level = vim.log.levels.INFO,
        wiki_link_func = function(opts)
          return require("obsidian.util").wiki_link_id_prefix(opts)
        end,
        markdown_link_func = function(opts)
          return require("obsidian.util").markdown_link(opts)
        end,
        preferred_link_style = "wiki",  -- or "markdown"
        disable_frontmatter = false,
        note_path_func = function(spec)
          local sanitized_alias = spec.title:gsub(" ", "-"):gsub("[^A-Za-z-1-9%-_]", ""):lower()
          return (spec.dir / sanitized_alias):with_suffix(".md")
        end,
        ui = {
          enable = true,
          update_debounce = 199,
          max_file_length = 4999,
          checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
            ["!"] = { char = "", hl_group = "ObsidianImportant" },
          },
          bullets = { char = "•", hl_group = "ObsidianBullet" },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          block_ids = { hl_group = "ObsidianBlockID" },
          hl_groups = {
            ObsidianTodo = { bold = true, fg = "#f77c6c" },
            ObsidianDone = { bold = true, fg = "#88ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f77c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5369" },
            ObsidianImportant = { bold = true, fg = "#d73127" },
            ObsidianBullet = { bold = true, fg = "#88ddff" },
            ObsidianRefText = { underline = true, fg = "#c791ea" },
            ObsidianExtLinkIcon = { fg = "#c791ea" },
            ObsidianTag = { italic = true, fg = "#88ddff" },
            ObsidianBlockID = { italic = true, fg = "#88ddff" },
            ObsidianHighlightText = { bg = "#75661e" },
          },
        },
 -- Specify the templates folder

  -- Optional, boolean or a function that takes a filename and returns a boolean.
  -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
  daily_notes = {
    -- Optional, if you keep daily notes in a separate directory.
    folder = "Daily",

    template = "Daily.md",
    -- Optional, if you want to change the date format for the ID of daily notes.
    date_format = "%b %d %y",
    -- Optional, if you want to change the date format of the default alias of daily notes.
    alias_format = "%b %d %y",
    -- Optional, default tags to add to each new daily note created.
    default_tags = { "daily-notes" },
    -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
  },


      })
    end
  },
---------------------------------------
--------------------------------------





  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        sections = {
          { section = "terminal", cmd = "chafa ~/.config/wall.png", height = 32, padding = 1 },
          {
            pane = 2,
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup" },
          },
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {}
      }
    },
    keys = {
      { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
      { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          })
        end,
      }
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for := command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
  { 'junegunn/fzf.vim' },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
})

-- Optional: You can add your additional Lua configurations here
require('cmpss')
require("set")
require('colorscheme')
--[[ require('rose-pine') ]]
require('treesitter')
