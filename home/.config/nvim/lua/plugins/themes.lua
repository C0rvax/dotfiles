return {
  { "redshifttt/tonight.nvim" },
  { "baliestri/aura-theme" },
  { "EdenEast/nightfox.nvim" },
  { "navarasu/onedark.nvim" },
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "moon", -- Choix entre "night", "storm", "day", "moon"..
        transparent = false,
        terminal_colors = true,
        styles = {
          variables = { bold = false, italic = false, underline = false },
          comments = { bold = true, italic = true, underline = false },
          keywords = { bold = false, italic = true, underline = false },
          functions = { bold = true, italic = false, underline = false },
        },
      })
    end,
  },
}
--{ "LazyVim/LazyVim", opts = { colorscheme = "duskfox", background = "day" } },
--{ "LazyVim/LazyVim", opts = { colorscheme = "terafox" } },
--{ "LazyVim/LazyVim", opts = { colorscheme = "Zaibatsu" } },
--{ "LazyVim/LazyVim", opts = { colorscheme = "tonight" } },
--{ "LazyVim/LazyVim", opts = { colorscheme = "lunaperche" } },
--{ "LazyVim/LazyVim", opts = { colorscheme = "nordfox" } },
