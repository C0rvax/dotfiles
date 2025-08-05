local M = {}

-- Toggle Copilot
local copilot_active = false
function M.ToggleCopilot()
  copilot_active = not copilot_active
  if copilot_active then
    vim.cmd("Copilot enable")
    print("Copilot activé")
  else
    vim.cmd("Copilot disable")
    print("Copilot désactivé")
  end
end

-- Toggle Blink.cmp
function M.ToggleBlinkCmp()
  local status = vim.b.completion
  if status == nil then status = true end
  vim.b.completion = not status
  print("blink.cmp: " .. (vim.b.completion and "activé" or "désactivé"))
end

return M
