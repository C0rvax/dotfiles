-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- disable auto-format for c and cpp languages
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "c" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "cpp" },
  callback = function()
    vim.b.autoformat = false
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "VMLeave",
  callback = function()
    vim.cmd("stopinsert") -- Réinitialise le mode d'insertion
    vim.cmd("startinsert") -- Retourne dans le mode insertion proprement
  end,
})
