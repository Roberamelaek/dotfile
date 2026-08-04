local DEFAULT_KIND_FILTER = {
  "Class",
  "Constructor",
  "Enum",
  "Field",
  "Function",
  "Interface",
  "Method",
  "Module",
  "Namespace",
  "Package",
  "Property",
  "Struct",
  "Trait",
}

-- Replacement for LazyVim.pick(): returns a function that opens the given
-- telescope builtin, defaulting to the git root as cwd (unless root = false).
-- Requires are deferred so telescope stays lazy-loaded.
local function pick(name, opts)
  opts = opts or {}
  return function()
    local builtin = require("telescope.builtin")
    local o = vim.deepcopy(opts)
    if name == "config_files" then
      o.cwd = vim.fn.stdpath("config")
      name = "find_files"
    elseif name == "files" then
      name = "find_files"
      o.follow = o.follow ~= false
      o.hidden = o.hidden ~= false
    end
    if o.cwd == nil and o.root ~= false then
      o.cwd = vim.fs.root(0, ".git")
    end
    o.root = nil
    builtin[name](o)
  end
end

return {
  'nvim-telescope/telescope.nvim', version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- optional but recommended
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    {
      "<leader>,",
      "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
      desc = "Switch Buffer",
    },
    { "<leader>/", pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader><space>", pick("files"), desc = "Find Files (Root Dir)" },
    -- find
    {
      "<leader>fb",
      "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
      desc = "Buffers",
    },
    { "<leader>fB", "<cmd>Telescope buffers<cr>", desc = "Buffers (all)" },
    { "<leader>fc", pick("config_files"), desc = "Find Config File" },
    { "<leader>ff", pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
    { "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
    -- git
    { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
    { "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
    { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
    { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },
    -- search
    { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
    { "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Lines" },
    { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer Diagnostics" },
    { "<leader>sg", pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>sG", pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
    { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
    { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
    { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
    { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
    { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
    { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
    { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
    { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
    { "<leader>sw", pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
    { "<leader>sW", pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
    { "<leader>sw", pick("grep_string"), mode = "x", desc = "Selection (Root Dir)" },
    { "<leader>sW", pick("grep_string", { root = false }), mode = "x", desc = "Selection (cwd)" },
    { "<leader>uC", pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
    {
      "<leader>ss",
      function()
        require("telescope.builtin").lsp_document_symbols({
          symbols = DEFAULT_KIND_FILTER,
        })
      end,
      desc = "Goto Symbol",
    },
    {
      "<leader>sS",
      function()
        require("telescope.builtin").lsp_dynamic_workspace_symbols({
          symbols = DEFAULT_KIND_FILTER,
        })
      end,
      desc = "Goto Symbol (Workspace)",
    },
  },
}
