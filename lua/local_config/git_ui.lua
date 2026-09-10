local M = {}

function M.branches(root)
  if not root and vim.bo.filetype == "neo-tree" then
    local state = require("neo-tree.sources.manager").get_state_for_window()
    root = state and state.path
  end
  root = root or vim.g.neovim_project_directory or LazyVim.root()
  Snacks.picker.git_branches({ cwd = root, all = true, title = "Switch Branch" })
end

return M
