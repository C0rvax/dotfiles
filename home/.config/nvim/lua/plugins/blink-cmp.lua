return {
  "saghen/blink.cmp",
  --	version = "v0.9.3",
  dependencies = {
    "moyiz/blink-emoji.nvim",
  },
  sources = {
    default = { "snippets", "lsp", "path", "buffer", "emoji" },
    providers = {
      snippets = {
        min_keyword_length = 2,
        score_offset = 1000,
      },
      lsp = {
        min_keyword_length = 3,
        score_offset = 900,
      },
      path = {
        min_keyword_length = 3,
        score_offset = 300,
      },
      buffer = {
        min_keyword_length = 5,
        score_offset = 200,
      },
      emoji = {
        module = "blink-emoji",
        name = "Emoji",
        score_offset = 800,
        min_keyword_length = 2,
        opts = { insert = true },
      },
    },
  },
  opts = {
    keymap = {
      ["<C-k>"] = { "snippet_backward" }, -- Précédent
      ["<C-j>"] = { "snippet_forward" }, -- Suivant
      ["<C-b>"] = { "scroll_documentation_up" },
      ["<C-f>"] = { "scroll_documentation_down" },
      ["<C-Space>"] = { "show" }, -- Affiche les suggestions

      -- Valide l'élément sélectionné
      ["<CR>"] = { "select_and_accept", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      [","] = { "hide", "fallback" },
    },
  },
}
