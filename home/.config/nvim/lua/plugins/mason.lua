return {
  {
    "mason-org/mason.nvim",
    -- Vous pouvez décommenter la ligne suivante pour épingler à une version spécifique
--     version = "1.11.0",
    opts = {
      ensure_installed = {
        "stylua", --Formater for lua
        "shellcheck", --Static analyzer for shell scripts
        "shfmt", --Formater for shell scripts
        "flake8", --Linter for python (detects errors and bad syntax)
        "clangd", --LSP server for C/C++
        "tailwindcss-language-server",
        "tinymist",
        "css-variables-language-server",
        "typescript-language-server",
        "superhtml",
        },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    -- Vous pouvez décommenter la ligne suivante pour épingler à une version spécifique
    -- version = "1.32.0",
    opts = {
    },
  },
}
