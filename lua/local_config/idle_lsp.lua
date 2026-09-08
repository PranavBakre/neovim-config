-- Release language-server memory while this editor window is unfocused.
-- Buffers remain open (including unsaved edits); servers rebuild on return.
local M = { sleeping = false, paused = {} }
local generation = 0

function M.sleep()
  M.sleeping = true
  for _, client in ipairs(vim.lsp.get_clients()) do
    if vim.lsp.is_enabled(client.name) then
      M.paused[client.name] = true
      vim.lsp.enable(client.name, false)
    end
  end
end

function M.wake()
  generation = generation + 1
  M.sleeping = false
  local paused = M.paused
  M.paused = {}
  for name in pairs(paused) do
    vim.lsp.enable(name, true)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("IdleLanguageServers", { clear = true })
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      generation = generation + 1
      local scheduled = generation
      vim.defer_fn(function()
        if scheduled == generation then
          M.sleep()
        end
      end, vim.g.idle_lsp_timeout_ms or 300000)
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = M.wake })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function()
      vim.schedule(function()
        if M.sleeping then
          M.sleep()
        end
      end)
    end,
  })
  vim.api.nvim_create_user_command("LspSleep", M.sleep, { desc = "Stop language servers until focus returns" })
  vim.api.nvim_create_user_command("LspWake", M.wake, { desc = "Restart sleeping language servers" })
  vim.api.nvim_create_user_command("LspSleepStatus", function()
    vim.notify(vim.inspect({ sleeping = M.sleeping, paused = M.paused, active = #vim.lsp.get_clients() }))
  end, {})
end
return M
