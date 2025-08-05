-- -- Keymaps are automatically loaded on the VeryLazy event
-- -- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- -- Add any additional keymaps here
--
-- local map = vim.keymap.set
-- local opts = { noremap = true, silent = true }
--
-- map("t", "<Esc>", "<C-\\><C-n>")
-- map("n", "<Leader>w", ":w!<cr>", { desc = "Save" })
-- map("n", "<Leader>q", ":q!<cr>", { desc = "Quit" })
-- map("n", "<space>", "/", opts)
-- map("n", "<leader>k", "<cmd>normal! <C-b><CR>", opts)
-- map("n", "<leader>j", "<cmd>normal! <C-f><CR>", opts)
--
-- --Toggle blink.cmp
-- vim.keymap.set("n", "<leader>ue", function()
--   vim.api.nvim_buf_set_var(0, "completion", false)
-- end, { desc = "Disable blink.cmp for current buffer" })
-- vim.keymap.set("n", "<leader>uE", function()
--   vim.api.nvim_buf_set_var(0, "completion", true)
-- end, { desc = "Enable blink.cmp for current buffer" })
--
-- --Brackets parenthesis quote
-- map("v", "<Leader>(", "<esc>`>a)<esc>`<i(<esc>", { desc = "parenthesis" })
-- map("n", "<Leader>r", "0i{<CR><esc>o}<esc>k", { desc = "bracket" })
-- map("v", "<Leader>'", ':s/\\%V\\(.*\\)\\%V/"\\1"/<CR>', opts)
-- map("v", '<Leader>"', ":s/\\%V\\(.*\\)\\%V/'\\1'/<CR>", opts)
-- map("v", "<Leader>[", ":s/\\%V\\(.*\\)\\%V/[\\1]/<CR>", opts)
-- map("v", "<Leader>{", ":s/\\%V\\(.*\\)\\%V/{\\1}/<CR>", opts)
--
-- --floating terminal
-- map("n", "<leader>ft", function()
--   Snacks.terminal(nil, { win = { position = "float" } })
-- end, { desc = "Floating Terminal" })
--
-- -- Toggle copilot
-- local copilot_active = false
-- function ToggleCopilot()
--   copilot_active = not copilot_active
--   if copilot_active then
--     vim.cmd("Copilot enable")
--     print("Copilot activé")
--   else
--     vim.cmd("Copilot disable")
--     print("Copilot désactivé")
--   end
-- end
--
-- -- Associe la fonction ToggleCopilot à la combinaison <leader>cp
-- map("n", "<leader>cp", ToggleCopilot, { noremap = true, silent = true, desc = "Bascule Copilot" })
--
-- -- tabs
-- map("n", "<leader>te", ":tabedit ", opts)
-- map("n", "<Leader>x", ":bd<CR>", opts)
-- map("n", "<Tab>", ":bnext<CR>", opts)
-- map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
-- map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
-- map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
-- map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close Tab" })
-- map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
--
-- -- Goto
-- map("n", "<leader>gd", ":lua vim.lsp.buf.definition()<CR>")
-- map("n", "<leader>gv", ":vsplit | lua vim.lsp.buf.definition()<CR>")
--
-- -- Mappage pour la recherche globale (sur tout le disque)
-- map("n", "<leader>a", "<cmd>lua require('fzf-lua').live_grep({ cwd = '/home/c0rvax'})<CR>", { desc = "Grep root" })
-- keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local fn = require("config.functions")

-- Terminal mode
map("t", "<Esc>", "<C-\\><C-n>")

-- Basic
map("n", "<Leader>w", ":w!<cr>", { desc = "Save" })
map("n", "<Leader>q", ":q!<cr>", { desc = "Quit" })
map("n", "<Leader>x", ":bd<cr>", { desc = "Close Buffer" })
map("n", "<Leader>n", ":nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<Leader>ss", ":wa<cr>", { desc = "Save all" })

-- Scrolling
map("n", "<leader>k", "<C-b>H", { desc = "Scroll up & move cursor to top" })
map("n", "<leader>j", "<C-f>L", { desc = "Scroll down & move cursor to bottom" })
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Completion toggle
map("n", "<leader>ub", fn.ToggleBlinkCmp, { desc = "Toggle blink.cmp for current buffer" })

-- Copilot toggle
map("n", "<leader>cp", fn.ToggleCopilot, { desc = "Toggle Copilot" })

-- Brackets / quotes
map("v", "<Leader>(", "<esc>`>a)<esc>`<i(<esc>", { desc = "Parenthesis" })
map("n", "<Leader>r", "0i{<CR><esc>o}<esc>k", { desc = "Insert bracket block" })
map("v", "<Leader>'", ':s/\\%V\\(.*\\)\\%V/"\\1"/<CR>', opts)
map("v", '<Leader>"', ":s/\\%V\\(.*\\)\\%V/'\\1'/<CR>", opts)
map("v", "<Leader>[", ":s/\\%V\\(.*\\)\\%V/[\\1]/<CR>", opts)
map("v", "<Leader>{", ":s/\\%V\\(.*\\)\\%V/{\\1}/<CR>", opts)

-- Terminal
map("n", "<leader>ft", function()
  Snacks.terminal(nil, { win = { position = "float" } })
end, { desc = "Floating Terminal" })

map("n", "<leader>tt", ":split | terminal<CR>", { desc = "Split Terminal" })

-- Tabs
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<leader>te", ":tabedit ", opts)
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close Tab" })

-- Goto
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>gv", ":vsplit | lua vim.lsp.buf.definition()<CR>", { desc = "Vertical Split Goto" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })

-- FZF
map("n", "<leader>a", "<cmd>lua require('fzf-lua').live_grep({ cwd = '/home/c0rvax'})<CR>", { desc = "Grep root" })
