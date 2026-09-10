local M = {}

function M.open(root, explicit_directory)
  Snacks.picker.files({
    cwd = root,
    hidden = explicit_directory or false,
    ignored = explicit_directory or false,
    title = "Open File — type a path and press Enter",
    confirm = function(picker, item)
      local input = vim.trim(picker.input:get())
      local path = input
      if path:sub(1, 2) == "~/" then
        path = vim.fn.expand("~") .. path:sub(2)
      elseif path:sub(1, 1) ~= "/" then
        path = root .. "/" .. path
      end
      local stat = input ~= "" and vim.uv.fs_stat(path) or nil
      if not stat then
        return Snacks.picker.actions.jump(picker, item)
      end
      picker:close()
      vim.schedule(function()
        if stat.type == "directory" then
          M.open(path, true)
        elseif stat.type == "file" then
          -- Keep the terminal dock intact when quick-open started there.
          if vim.bo.buftype ~= "" then
            local target
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                target = win
                break
              end
            end
            if target then
              vim.api.nvim_set_current_win(target)
            else
              vim.cmd.vnew()
            end
          end
          vim.cmd.edit(vim.fn.fnameescape(path))
        end
      end)
    end,
  })
end

return M
