local M = {}
local ns = vim.api.nvim_create_namespace("ProjectActivityBar")

function M.select(source)
  require("neo-tree.command").execute({
    source = source,
    action = "focus",
    dir = vim.g.neovim_project_directory or vim.fn.getcwd(),
  })
  M.highlight(source)
  M.position()
end

function M.highlight(source)
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
    vim.api.nvim_buf_add_highlight(M.buf, ns, "Visual", source == "git_status" and 3 or 1, 0, -1)
  end
end

function M.position()
  if M.busy or not M.win or not vim.api.nvim_win_is_valid(M.win) then
    return
  end
  M.busy = true
  -- Moving an already-leftmost split redistributes widths on every click.
  -- Only rearrange the layout when a newly opened sidebar displaced the bar.
  if vim.api.nvim_win_get_position(M.win)[2] ~= 0 then
    local previous = vim.api.nvim_get_current_win()
    local widths = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
        widths[win] = vim.api.nvim_win_get_width(win)
      end
    end
    vim.api.nvim_set_current_win(M.win)
    vim.cmd("noautocmd wincmd H")
    if vim.api.nvim_win_is_valid(previous) then
      vim.api.nvim_set_current_win(previous)
    end
    for win, width in pairs(widths) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_width(win, width)
      end
    end
  end
  vim.api.nvim_win_set_width(M.win, 5)
  M.busy = false
end

function M.open()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    return
  end
  local previous = vim.api.nvim_get_current_win()
  M.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[M.buf].filetype = "activitybar"
  vim.bo[M.buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, { "", " ", "", " " })
  vim.bo[M.buf].modifiable = false
  M.win = vim.api.nvim_open_win(M.buf, false, { split = "left", win = -1, width = 5 })
  for name, value in pairs({
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
    winfixwidth = true,
    wrap = false,
    cursorline = false,
    winbar = "",
    statusline = " ",
    fillchars = "eob: ",
    winhighlight = "Normal:NormalFloat,EndOfBuffer:NormalFloat",
  }) do
    vim.wo[M.win][name] = value
  end
  local function activate()
    local line = vim.api.nvim_win_get_cursor(M.win)[1]
    if line == 2 then
      M.select("filesystem")
    elseif line == 4 then
      M.select("git_status")
    end
  end
  for _, key in ipairs({ "<LeftRelease>", "<2-LeftRelease>", "<3-LeftRelease>", "<4-LeftRelease>" }) do
    vim.keymap.set({ "n", "v" }, key, activate, { buffer = M.buf, nowait = true, desc = "Switch sidebar" })
  end
  vim.keymap.set("n", "<CR>", activate, { buffer = M.buf, nowait = true, desc = "Switch sidebar" })
  vim.keymap.set("n", "f", function()
    M.select("filesystem")
  end, { buffer = M.buf })
  vim.keymap.set("n", "g", function()
    M.select("git_status")
  end, { buffer = M.buf })
  vim.api.nvim_set_current_win(previous)
  M.highlight("filesystem")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ProjectActivityBar", { clear = true })
  vim.api.nvim_create_autocmd("WinNew", {
    group = group,
    callback = function()
      vim.schedule(M.position)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    callback = function()
      if vim.bo.filetype == "neo-tree" then
        vim.wo.winbar = ""
        M.highlight(vim.b.neo_tree_source)
      end
    end,
  })
  vim.schedule(M.open)
end

return M
