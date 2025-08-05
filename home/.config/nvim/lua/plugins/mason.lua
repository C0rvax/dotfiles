return {
  {
    "williamboman/mason.nvim",
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
}
