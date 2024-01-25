return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        tsserver = {},
        html = {},
        tailwindcss = {},
        prismals = {},
        cssls = {
          filetypes = {
            "html",
            "css",
          },
        },
        emmet_ls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescriptreact",
            "typescript",
            "javascript.jsx",
            "typescript.tsx",
          },
        },
      },
    },
  }, -- configure html server   -- configure html server
}
