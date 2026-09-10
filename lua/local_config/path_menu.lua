local M = {}

local function selected_path()
  if vim.bo.filetype == "neo-tree" then
    local state = require("neo-tree.sources.manager").get_state_for_window()
    local node = state and state.tree and state.tree:get_node()
    return node and node.path or nil
  end
  if vim.bo.buftype == "" then
    local name = vim.api.nvim_buf_get_name(0)
    return name ~= "" and name or nil
  end
end

local function relative(path, root)
  local target = vim.split(vim.fs.normalize(path), "/", { trimempty = true })
  local base = vim.split(vim.fs.normalize(root), "/", { trimempty = true })
  local common = 0
  while target[common + 1] and target[common + 1] == base[common + 1] do
    common = common + 1
  end
  local parts = {}
  for _ = common + 1, #base do
    parts[#parts + 1] = ".."
  end
  for i = common + 1, #target do
    parts[#parts + 1] = target[i]
  end
  return #parts > 0 and table.concat(parts, "/") or "."
end

function M.capture()
  M.sidebar = vim.bo.filetype == "neo-tree" and require("neo-tree.sources.manager").get_state_for_window() or nil
  local hidden_action = M.sidebar and M.sidebar.name == "filesystem" and "enable" or "disable"
  vim.cmd("amenu " .. hidden_action .. [[ PopUp.View\ Hidden\ Files]])
  local path = selected_path()
  M.absolute = path and vim.fn.fnamemodify(path, ":p"):gsub("/+$", "") or nil
  if M.absolute == "" then
    M.absolute = "/"
  end
  local root = vim.g.neovim_project_directory or LazyVim.root()
  M.relative = M.absolute and relative(vim.uv.fs_realpath(M.absolute) or M.absolute, vim.uv.fs_realpath(root) or root)
    or nil
  local action = M.absolute and "enable" or "disable"
  vim.cmd("amenu " .. action .. [[ PopUp.Copy\ Relative\ Path]])
  vim.cmd("amenu " .. action .. [[ PopUp.Copy\ Absolute\ Path]])
end

function M.copy(kind)
  local path = M[kind]
  if type(path) == "string" then
    vim.fn.setreg("+", path)
  end
end

function M.toggle_hidden()
  if M.sidebar and M.sidebar.name == "filesystem" then
    require("neo-tree.sources.filesystem.commands").toggle_hidden(M.sidebar)
  end
end

function M.setup()
  vim.cmd([[
    anoremenu PopUp.Switch\ Branch <Cmd>lua require('local_config.git_ui').branches()<CR>
    anoremenu PopUp.View\ Hidden\ Files <Cmd>lua require('local_config.path_menu').toggle_hidden()<CR>
    anoremenu PopUp.Copy\ Relative\ Path <Cmd>lua require('local_config.path_menu').copy('relative')<CR>
    anoremenu PopUp.Copy\ Absolute\ Path <Cmd>lua require('local_config.path_menu').copy('absolute')<CR>
  ]])
  vim.api.nvim_create_autocmd("MenuPopup", {
    group = vim.api.nvim_create_augroup("ProjectPathMenu", { clear = true }),
    callback = M.capture,
  })
end

return M
