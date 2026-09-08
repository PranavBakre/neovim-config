local M = {}

-- Inspect the clicked buffer directly so terminal clicks never reach the shell.
function M.open()
  local pos = vim.fn.getmousepos()
  if pos.winid == 0 or pos.line < 1 or pos.column < 1 then
    return
  end
  local buf = vim.api.nvim_win_get_buf(pos.winid)
  local line = vim.api.nvim_buf_get_lines(buf, pos.line - 1, pos.line, false)[1] or ""
  local from = 1
  while true do
    local first, last = line:find("https?://[^%s<>\"'`]+", from)
    if not first then
      break
    end
    local url = line:sub(first, last):gsub("[.,;:!?]+$", "")
    -- Remove prose/Markdown closing brackets, preserving balanced URL brackets.
    for _, pair in ipairs({ { "(", ")" }, { "[", "]" }, { "{", "}" } }) do
      while url:sub(-1) == pair[2] do
        local _, opens = url:gsub("%" .. pair[1], "")
        local _, closes = url:gsub("%" .. pair[2], "")
        if closes <= opens then
          break
        end
        url = url:sub(1, -2)
      end
    end
    if pos.column >= first and pos.column < first + #url then
      local _, err = vim.ui.open(url)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
      end
      return
    end
    from = last + 1
  end
  if vim.bo[buf].buftype == "" then
    vim.api.nvim_set_current_win(pos.winid)
    vim.api.nvim_win_set_cursor(pos.winid, { pos.line, pos.column - 1 })
    vim.lsp.buf.definition()
  end
end

return M
