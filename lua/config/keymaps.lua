local map = vim.keymap.set
local function project_root()
  if vim.g.neovim_project_directory then
    return vim.g.neovim_project_directory
  end
  local term = vim.b.snacks_terminal
  if term and term.cwd then
    return term.cwd
  end
  return LazyVim.root()
end
map({ "n", "i", "v" }, "<D-s>", "<Cmd>write<CR>", { desc = "Save file" })
map({ "n", "i", "v" }, "<D-p>", function()
  Snacks.picker.files({ cwd = project_root() })
end, { desc = "Quick open" })
map({ "n", "i", "v" }, "<D-S-p>", function()
  Snacks.picker.commands()
end, { desc = "Command palette" })
map({ "n", "i", "v" }, "<D-S-f>", function()
  Snacks.picker.grep({ cwd = project_root() })
end, { desc = "Search project" })
map({ "n", "i", "v" }, "<D-b>", "<Cmd>Neotree toggle<CR>", { desc = "Toggle explorer" })
map({ "n", "i", "v" }, "<D-w>", function()
  Snacks.bufdelete()
end, { desc = "Close file" })
local function terminal()
  require("local_config.terminal_dock").toggle(project_root())
end
for _, key in ipairs({ "<D-`>", "<C-`>", "<C-/>", "<C-_>" }) do
  map({ "n", "i", "v", "t" }, key, terminal, { desc = "Toggle project terminal" })
end
vim.api.nvim_create_user_command("ProjectTerminal", terminal, { desc = "Toggle bottom project terminal", force = true })
map("v", "<D-c>", '"+y', { desc = "Copy" })
map("v", "<D-x>", '"+d', { desc = "Cut" })
map({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste" })
map("i", "<D-v>", "<C-r>+", { desc = "Paste" })
map({ "n", "i", "v" }, "<D-a>", "<Esc>ggVG", { desc = "Select all" })
map({ "n", "i" }, "<D-z>", "<Cmd>undo<CR>", { desc = "Undo" })
map({ "n", "i" }, "<D-S-z>", "<Cmd>redo<CR>", { desc = "Redo" })

-- Open web links in files and terminal output, or navigate code symbols.
map({ "n", "i", "v", "t" }, "<D-LeftMouse>", function()
  require("local_config.mouse").open()
end, { desc = "Open clicked link or definition" })
map({ "n", "i", "v", "t" }, "<D-LeftRelease>", "<Nop>")
map({ "n", "i", "v", "t" }, "<D-LeftDrag>", "<Nop>")
map(
  { "n", "i", "v" },
  "<D-M-LeftMouse>",
  "<LeftMouse><Cmd>lua vim.lsp.buf.implementation()<CR>",
  { desc = "Go to clicked implementation" }
)
map({ "n", "i", "v" }, "<F12>", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "i", "v" }, "<D-F12>", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map({ "n", "i", "v" }, "<S-F12>", vim.lsp.buf.references, { desc = "Find references" })
map({ "n", "i" }, "<C-o>", "<Esc><C-o>", { desc = "Go back" })
map({ "n", "i", "v" }, "<D-t>", function()
  Snacks.picker.lsp_workspace_symbols({ cwd = project_root() })
end, { desc = "Go to symbol" })
-- Finder and terminal buffers also support quick file search.
map("t", "<D-p>", function()
  vim.cmd.stopinsert()
  vim.schedule(function()
    Snacks.picker.files({ cwd = project_root() })
  end)
end, { desc = "Quick open" })

local function new_terminal()
  require("local_config.terminal_dock").new(project_root())
end
map({ "n", "i", "t" }, "<D-S-`>", new_terminal, { desc = "New dock terminal" })
map({ "n", "i", "t" }, "<D-~>", new_terminal, { desc = "New dock terminal" })
map({ "n", "i", "t" }, "<D-S-j>", function()
  require("local_config.terminal_dock").select(project_root())
end, { desc = "Select dock terminal" })
vim.api.nvim_create_user_command("ProjectTerminalNew", new_terminal, { force = true })
vim.api.nvim_create_user_command("ProjectTerminals", function()
  require("local_config.terminal_dock").select(project_root())
end, { force = true })
vim.api.nvim_create_user_command("ProjectTerminalNext", function()
  require("local_config.terminal_dock").cycle(project_root(), 1)
end, { force = true })

-- Keep the final screenful visible rather than scrolling into empty space.
map({ "n", "i", "v", "t" }, "<ScrollWheelDown>", function()
  if vim.fn.pumvisible() == 1 then
    return "<ScrollWheelDown>"
  end
  local win = vim.fn.getmousepos().winid
  if win == 0 or not vim.api.nvim_win_is_valid(win) then
    return "<ScrollWheelDown>"
  end
  local at_end = vim.api.nvim_win_call(win, function()
    local view = vim.fn.winsaveview()
    local remaining = vim.api.nvim_win_text_height(win, { start_row = view.topline - 1 }).all
    return remaining - view.skipcol / math.max(1, vim.api.nvim_win_get_width(win)) <= vim.api.nvim_win_get_height(win)
  end)
  if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
    -- Resume shell input after the wheel event reaches the live output.
    vim.schedule(function()
      if vim.api.nvim_get_current_win() == win and vim.fn.mode() == "n" then
        local view = vim.fn.winsaveview()
        local remaining = vim.api.nvim_win_text_height(win, { start_row = view.topline - 1 }).all
        if remaining <= vim.api.nvim_win_get_height(win) then
          vim.cmd.startinsert()
        end
      end
    end)
  end
  return at_end and "" or "<ScrollWheelDown>"
end, { expr = true, desc = "Scroll down within content" })
