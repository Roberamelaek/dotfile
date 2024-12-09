-- plugins.lua
vim.notify = require("notify")
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- General Utilities
  use 'rstacruz/vim-closer' -- Automatically close parentheses, brackets, etc.
  use 'jiangmiao/auto-pairs' -- Auto-completion for brackets and quotes
  use 'tpope/vim-surround' -- Easily manipulate surrounding pairs like quotes, brackets, etc.
  use 'tpope/vim-commentary' -- Commenting utility
  use "nvim-lua/plenary.nvim"


  -- File Navigation
  use {
    'preservim/nerdtree', -- File tree explorer
    cmd = { 'NERDTreeToggle', 'NERDTreeFocus' } -- Lazy loading
  }
  use 'ryanoasis/vim-devicons' -- Icons for NERDTree and other plugins

  -- UI Enhancements
  use 'vim-airline/vim-airline' -- Status line
  use 'rcarriga/nvim-notify' -- Notification popups
  use 'rafi/awesome-vim-colorschemes' -- Collection of colorschemes
  use 'lifepillar/pgsql.vim' -- PostgreSQL syntax highlighting
  use {
	  'nvim-treesitter/nvim-treesitter',
	  run = ':TSUpdate'
  }

  -- Syntax Highlighting and Language Support
  use 'neoclide/coc.nvim' -- Intellisense and LSP support
  use 'ap/vim-css-color' -- Color preview for CSS
  use 'preservim/tagbar' -- Code navigation with tags

  -- Productivity
  use 'junegunn/fzf' -- Fuzzy finder
  use 'junegunn/fzf.vim' -- Fuzzy finder plugin for Vim
  use 'terryma/vim-multiple-cursors' -- Multi-cursor editing
--   use {
--     'iamcco/markdown-preview.nvim',
--     run = 'cd app && npm install',
--     ft = 'markdown' -- Load only for markdown files
--   }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- GitHub Copilot
  use {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_assume_mapped = true
    end,
  }
  -- Obsidian Support

  use {
  'epwalsh/obsidian.nvim',
  config = function()
	  require('obsidian').setup({

		  workspaces = {
			  {
				  name = "Self",
				  path = "~/.nb/home",
				  
			  },
		  },
		  completion = {
			  nvim_cmp = true,
			  min_chars = 2,
		  },
		    log_level = vim.log.levels.INFO,

		  wiki_link_func = function(opts)
			  return require("obsidian.util").wiki_link_id_prefix(opts)
		  end,

		  -- Optional, customize how markdown links are formatted.
		  markdown_link_func = function(opts)
			  return require("obsidian.util").markdown_link(opts)
		  end,

			-- Either 'wiki' or 'markdown'.
			preferred_link_style = "wiki",


  -- Optional, boolean or a function that takes a filename and returns a boolean.
  -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
		  disable_frontmatter = false,
note_path_func = function(spec)
  local sanitized_alias = spec.title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-_]", ""):lower()
  return (spec.dir / sanitized_alias):with_suffix(".md")
end,
  -- Optional, configure additional syntax highlighting / extmarks.
  -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
  ui = {
    enable = true,  -- set to false to disable all additional syntax features
    update_debounce = 200,  -- update delay after a text change (in milliseconds)
    max_file_length = 5000,  -- disable UI features for files with more than this many lines
    -- Define how various check-boxes are displayed
    checkboxes = {
      -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
      [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      ["x"] = { char = "", hl_group = "ObsidianDone" },
      [">"] = { char = "", hl_group = "ObsidianRightArrow" },
      ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      ["!"] = { char = "", hl_group = "ObsidianImportant" },
      -- Replace the above with this if you don't have a patched font:
      -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
      -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

      -- You can also add more custom ones...
    },
    -- Use bullet marks for non-checkbox lists.
    bullets = { char = "•", hl_group = "ObsidianBullet" },
    external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
    -- Replace the above with this if you don't have a patched font:
    -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
    reference_text = { hl_group = "ObsidianRefText" },
    highlight_text = { hl_group = "ObsidianHighlightText" },
    tags = { hl_group = "ObsidianTag" },
    block_ids = { hl_group = "ObsidianBlockID" },
    hl_groups = {
      -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
      ObsidianTodo = { bold = true, fg = "#f78c6c" },
      ObsidianDone = { bold = true, fg = "#89ddff" },
      ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
      ObsidianTilde = { bold = true, fg = "#ff5370" },
      ObsidianImportant = { bold = true, fg = "#d73128" },
      ObsidianBullet = { bold = true, fg = "#89ddff" },
      ObsidianRefText = { underline = true, fg = "#c792ea" },
      ObsidianExtLinkIcon = { fg = "#c792ea" },
      ObsidianTag = { italic = true, fg = "#89ddff" },
      ObsidianBlockID = { italic = true, fg = "#89ddff" },
      ObsidianHighlightText = { bg = "#75662e" },
    },
  },





			  })
		  end
		}


  -- Markdown Support
  use {
    'plasticboy/vim-markdown',
    ft = 'markdown', -- Load only for Markdown files
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
    end,
  }

  -- Git Integration
  use 'tpope/vim-fugitive' -- Git commands within Vim

  -- Lua Development
  use 'nvim-lua/plenary.nvim' -- Useful Lua functions used by lots of plugins

  -- Experimental
  use 'junegunn/goyo.vim' -- Distraction-free writing mode
  use 'junegunn/limelight.vim' -- Focus mode for writing

  -- Colorschemes
  use 'morhetz/gruvbox'
  use 'joshdick/onedark.vim'

    -- Completion plugin: nvim-cmp
    use {
        'hrsh7th/nvim-cmp',
        config = function()
            require('cmp').setup({
                -- Completion settings
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)  -- Use vsnip for snippets (or any other snippet engine)
                    end,
                },
                mapping = {
                    ['<C-p>'] = require('cmp').mapping.select_prev_item(),
                    ['<C-n>'] = require('cmp').mapping.select_next_item(),
                    ['<C-y>'] = require('cmp').mapping.confirm({ select = true }),
                    ['<C-e>'] = require('cmp').mapping.abort(),
                },
                sources = {
                    { name = 'nvim_lsp' },  -- LSP completion
                    { name = 'nvim_lua' },  -- Lua completion
                    { name = 'path' },      -- Path completion
                    { name = 'buffer' },    -- Buffer completion
                },
            })
        end
    }

    -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-nvim-lsp'

    -- Lua source for nvim-cmp (for Lua completion)
    use 'hrsh7th/cmp-nvim-lua'

    -- Buffer source for nvim-cmp
    use 'hrsh7th/cmp-buffer'

    -- Path source for nvim-cmp
    use 'hrsh7th/cmp-path'

    -- Snippet support (optional)
    use 'hrsh7th/vim-vsnip'  -- or use any other snippet engine like 'ultisnips' or 'luasnip'

    -- Optional: For additional LSP features, install the lspconfig plugin
    use 'neovim/nvim-lspconfig'

end)
