local M = { selected = {} }

local function terminals(root)
  local list = vim.tbl_filter(function(t)
    return vim.b[t.buf].snacks_terminal.cwd == root
  end, Snacks.terminal.list())
  table.sort(list, function(a, b)
    return vim.b[a.buf].snacks_terminal.id < vim.b[b.buf].snacks_terminal.id
  end)
  return list
end

local function show(root, id)
  for _, t in ipairs(Snacks.terminal.list()) do
    t:hide()
  end
  M.selected[root] = id
  local term = Snacks.terminal.get(nil, {
    cwd = root,
    count = id,
    win = { position = "bottom", height = 0.3, stack = false },
  })
  assert(term):show():focus()
  return term
end

function M.toggle(root)
  local id = M.selected[root] or 1
  for _, t in ipairs(terminals(root)) do
    if vim.b[t.buf].snacks_terminal.id == id and t:win_valid() then
      t:hide()
      return
    end
  end
  return show(root, id)
end

function M.new(root)
  local id = 0
  for _, t in ipairs(terminals(root)) do
    id = math.max(id, vim.b[t.buf].snacks_terminal.id)
  end
  return show(root, id + 1)
end

function M.select(root)
  local list = terminals(root)
  if #list == 0 then
    return M.new(root)
  end
  vim.ui.select(list, {
    prompt = "Project terminals",
    format_item = function(t)
      return "Terminal " .. vim.b[t.buf].snacks_terminal.id
    end,
  }, function(t)
    if t then
      show(root, vim.b[t.buf].snacks_terminal.id)
    end
  end)
end

function M.cycle(root, direction)
  local list = terminals(root)
  if #list == 0 then
    return M.new(root)
  end
  local current = 1
  for i, t in ipairs(list) do
    if vim.b[t.buf].snacks_terminal.id == (M.selected[root] or 1) then
      current = i
    end
  end
  local next_terminal = list[(current - 1 + direction) % #list + 1]
  return show(root, vim.b[next_terminal.buf].snacks_terminal.id)
end

return M
