return {
  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").config({
        providers = { "hover.providers.lsp", "hover.providers.diagnostic" },
        mouse_providers = { "hover.providers.lsp" },
        mouse_delay = 500,
        preview_opts = { border = "rounded" },
        preview_window = false,
      })
      vim.opt.mousemoveevent = true
      vim.keymap.set({ "n", "i" }, "<MouseMove>", function()
        require("hover").mouse()
      end, { desc = "Show type under mouse" })
      vim.keymap.set({ "n", "i" }, "<D-k>", function()
        require("hover").open()
      end, { desc = "Show type information" })
    end,
  },
}
