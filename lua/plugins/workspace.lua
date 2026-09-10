local function change_stage(state, stage)
  local node = state.tree:get_node()
  if not node or node.type == "message" then
    return
  end
  local result = vim.fn.system({ "git", "-C", state.path, stage and "add" or "reset", "--", node:get_id() })
  if vim.v.shell_error ~= 0 then
    vim.notify(result, vim.log.levels.ERROR)
    return
  end
  local events = require("neo-tree.events")
  events.fire_event(events.GIT_EVENT)
end

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      for i, component in ipairs(opts.sections.lualine_b) do
        if component == "branch" or (type(component) == "table" and component[1] == "branch") then
          component = type(component) == "table" and component or { "branch" }
          component.on_click = function()
            require("local_config.git_ui").branches()
          end
          opts.sections.lualine_b[i] = component
        end
      end
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        custom_filter = function(buf)
          return vim.bo[buf].buftype ~= "terminal"
        end,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { width = 30, mappings = { ["<LeftRelease>"] = "open" } },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline", "activitybar" },
      source_selector = {
        winbar = false,
        sources = {
          { source = "filesystem", display_name = "Files" },
          { source = "git_status", display_name = "Git" },
        },
      },
      git_status = {
        window = {
          mappings = {
            ["b"] = function(state)
              require("local_config.git_ui").branches(state.path)
            end,
            ["s"] = function(state)
              change_stage(state, true)
            end,
            ["u"] = function(state)
              change_stage(state, false)
            end,
            ["d"] = function(state)
              Snacks.picker.git_diff({ cwd = state.path })
            end,
            ["<D-CR>"] = function(state)
              Snacks.lazygit({ cwd = state.path })
            end,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { enabled = false },
        tsgo = { enabled = false },
        tsc = {
          mason = false,
          cmd = {
            vim.fn.stdpath("data") .. "/typescript-native/node_modules/.bin/tsc",
            "--lsp",
            "--stdio",
          },
          -- Use the editor's pinned native server even when the project uses TS 5.
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { ".git", "tsconfig.json", "jsconfig.json", "package.json" }) or vim.fn.getcwd())
          end,
        },
      },
    },
  },
}
