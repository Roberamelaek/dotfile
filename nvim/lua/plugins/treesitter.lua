return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- Install parsers asynchronously on first startup; no blocking :wait().
    require('nvim-treesitter').install {
      'bash', 'c', 'cmake', 'comment', 'cpp', 'css', 'diff', 'dockerfile', 'go',
      'html', 'java', 'javascript', 'json', 'json5', 'lua', 'make', 'markdown',
      'markdown_inline', 'python', 'query', 'regex', 'sql', 'toml', 'tsx',
      'typescript', 'vim', 'vimdoc', 'xml', 'yaml',
    }
  end,
}
