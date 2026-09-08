vim.opt.mouse = "a"
-- Prevent sideways trackpad drift; one-line steps allow an exact EOF stop.
vim.opt.mousescroll = "ver:1,hor:0"
vim.opt.clipboard = "unnamedplus"
vim.opt.relativenumber = false
vim.opt.confirm = true
vim.opt.showtabline = 2
vim.g.lazyvim_ts_lsp = "tsgo"
vim.g.idle_lsp_timeout_ms = 300000
if vim.g.neovide then
  vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_refresh_rate_idle = 5
end

-- Resolve folder arguments before startup completes, while relative paths
-- still refer to the shell directory used to launch Neovide.
local folder_arg = vim.fn.argv(0)
if type(folder_arg) == "string" and vim.fn.isdirectory(folder_arg) == 1 then
  local folder = vim.fn.fnamemodify(folder_arg, ":p"):gsub("/$", "")
  vim.g.neovim_project_directory = folder
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.api.nvim_set_current_dir(folder)
    end,
  })
end
