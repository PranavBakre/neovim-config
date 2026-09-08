return {
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
