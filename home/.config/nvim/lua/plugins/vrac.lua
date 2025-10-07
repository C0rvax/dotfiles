return {
  { "hrsh7th/lspkind-nvim" },
  { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
  { "lewis6991/gitsigns.nvim" },
  { "nvim-lualine/lualine.nvim", opts = {} },
--   { "puremourning/vimspector" },
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
}
--    { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-emoji",},},
--    { 'hrsh7th/cmp-nvim-lsp' },
--    { 'hrsh7th/cmp-buffer' },
--    { 'hrsh7th/cmp-path' },
--    { "saadparwaiz1/cmp_luasnip" },

--    { 'L3MON4D3/LuaSnip', build = "make install_jsregexp"},
--    { "mg979/vim-visual-multi"},
