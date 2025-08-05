return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "cpp",
        "elixir",
        "heex",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
}
