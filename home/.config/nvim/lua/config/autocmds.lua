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
    vim.cmd("stopinsert") -- Resets insert mode
    vim.cmd("startinsert") -- Returns to insert mode cleanly
  end,
})

-- Handles automatic creation of a .clangd file for STM32 projects
local augroup = vim.api.nvim_create_augroup("MyCustomLsp", { clear = true })

-- Content of the .clangd file to be created
local clangd_stm32_config = [[
# Fichier auto-généré par la configuration Neovim pour les projets STM32
CompileFlags:
  Add:
    - -I/usr/lib/gcc/arm-none-eabi/13.2.1/include
    - -I/usr/lib/gcc/arm-none-eabi/13.2.1/include-fixed
    - -I/usr/lib/gcc/arm-none-eabi/13.2.1/../../../arm-none-eabi/include
]]

-- This function is called when an LSP server attaches to a buffer
local function on_lsp_attach(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if not client or client.name ~= "clangd" then
    return
  end

  -- Find the root directory of the project
  local root = client.config.root_dir
  if not root then
    return
  end

  -- Detects if it's an STM32 project by looking for .ld files
  local linker_scripts = vim.fn.glob(root .. "/*.ld", false, true)
  if vim.tbl_isempty(linker_scripts) then
    return
  end

  -- Check if the .clangd file already exists
  local clangd_file_path = root .. "/.clangd"
  if vim.fn.filereadable(clangd_file_path) == 1 then
    return
  end

  -- If we reach here, it's an STM32 project and .clangd doesn't exist
  vim.notify("Projet STM32 détecté. Création du fichier .clangd...", vim.log.levels.INFO)

  local file = io.open(clangd_file_path, "w")
  if file then
    file:write(clangd_stm32_config)
    file:close()
    -- Restart clangd to apply the new configuration
    vim.cmd("LspRestart clangd")
    vim.notify("Fichier .clangd créé. Le serveur clangd a été redémarré.", vim.log.levels.INFO)
  else
    vim.notify("Erreur: Impossible de créer le fichier .clangd.", vim.log.levels.ERROR)
  end
end

-- Attach the function to the LspAttach event
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = on_lsp_attach,
})
