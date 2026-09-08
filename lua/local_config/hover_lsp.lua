-- Resolve clients per request: servers may attach after hover loads or restart
-- after idle shutdown. hover.nvim's built-in provider snapshots them at startup.
local M = { name = "LSP", priority = 1000 }

function M.enabled(bufnr)
  return #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" }) > 0
end

function M.execute(params, done)
  local clients = vim.lsp.get_clients({ bufnr = params.bufnr, method = "textDocument/hover" })
  local index = 0
  local function next_client()
    index = index + 1
    local client = clients[index]
    if not client or not vim.api.nvim_buf_is_valid(params.bufnr) then
      done()
      return
    end
    local row, col = params.pos[1] - 1, params.pos[2]
    local line = vim.api.nvim_buf_get_lines(params.bufnr, row, row + 1, false)[1] or ""
    local request = {
      textDocument = { uri = vim.uri_from_bufnr(params.bufnr) },
      position = {
        line = row,
        character = vim.str_utfindex(line, client.offset_encoding, math.min(col, #line)),
      },
    }
    local sent = client:request("textDocument/hover", request, function(err, result)
      if not err and result and result.contents then
        local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        if #lines > 0 then
          done({ lines = lines, filetype = "markdown" })
          return
        end
      end
      next_client()
    end, params.bufnr)
    if not sent then
      next_client()
    end
  end
  next_client()
end

local mouse_generation = 0

function M.mouse()
  mouse_generation = mouse_generation + 1
  local generation = mouse_generation
  vim.defer_fn(function()
    if generation ~= mouse_generation or vim.fn.pumvisible() == 1 then
      return
    end
    local pos = vim.fn.getmousepos()
    if pos.winid == 0 or pos.line < 1 or pos.column < 1 then
      return
    end
    local buf = vim.api.nvim_win_get_buf(pos.winid)
    if vim.w[pos.winid].hover then
      return
    end
    require("hover").close(buf)
    if not M.enabled(buf) then
      return
    end
    -- Mouse columns are one-based; LSP provider positions are zero-based.
    M.execute({ bufnr = buf, pos = { pos.line, pos.column - 1 } }, function(result)
      if not result or not result.lines or generation ~= mouse_generation then
        return
      end
      local current = vim.fn.getmousepos()
      if
        vim.fn.pumvisible() == 1
        or not vim.api.nvim_win_is_valid(pos.winid)
        or current.winid ~= pos.winid
        or current.line ~= pos.line
        or current.column ~= pos.column
      then
        return
      end
      vim.api.nvim_win_call(pos.winid, function()
        require("hover.util").open_floating_preview(result.lines, nil, "markdown", {
          border = "rounded",
          relative = "mouse",
          focus = false,
        })
      end)
    end)
  end, 500)
end

return M
