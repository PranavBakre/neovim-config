return {
  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").config({
        providers = { "local_config.hover_lsp", "hover.providers.diagnostic" },
        mouse_providers = { "local_config.hover_lsp" },
        mouse_delay = 500,
        preview_opts = { border = "rounded" },
        preview_window = false,
      })
      vim.opt.mousemoveevent = true
      vim.keymap.set({ "n", "i" }, "<MouseMove>", function()
        -- Native context menus consume MouseMove themselves. A command mapping
        -- steals that event and can dismiss the menu instead of selecting an item.
        if vim.fn.pumvisible() == 1 then
          return "<MouseMove>"
        end
        -- Leave an existing popup alone while interacting with its contents.
        local mouse_win = vim.fn.getmousepos().winid
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local preview = vim.b[buf].hover_preview
          if preview and vim.api.nvim_win_is_valid(preview) then
            if mouse_win == preview or vim.api.nvim_get_current_win() == preview then
              return
            end
          end
        end
        require("local_config.hover_lsp").mouse()
        return "<MouseMove>"
      end, { expr = true, desc = "Show type under mouse" })
      -- Preserve Neovim's native right-click context menu.
      for _, mode in ipairs({ "n", "i" }) do
        local mapping = vim.fn.maparg("<RightMouse>", mode, false, true)
        if mapping.desc == "Focus type popup or open context menu" then
          vim.keymap.del(mode, "<RightMouse>")
        end
      end
      vim.keymap.set({ "n", "i" }, "<D-k>", function()
        require("hover").open()
      end, { desc = "Show type information" })
    end,
  },
}
