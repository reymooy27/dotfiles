return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        eslint = {},
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
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  }, -- configure html server   -- configure html server
}
