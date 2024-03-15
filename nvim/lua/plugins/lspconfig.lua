return {
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                -- pyright will be automatically installed with mason and loaded with lspconfig
                -- eslint = {},
                pyright = {},
                rust_analyzer = {
                    root_dir = function(...)
                        return require("lspconfig.util").root_pattern("Cargo.toml")(...)
                    end,
                    settings = {
                        ["rust-analyzer"] = {
                            procMacro = { enable = true },
                            cargo = { allFeatures = true },
                            checkOnSave = {
                                command = "clippy",
                                extraArgs = { "--no-deps" },
                            },
                        },
                    },
                },
                tsserver = {
                    root_dir = function(...)
                        return require("lspconfig.util").root_pattern(".git")(...)
                    end,
                    single_file_support = true,
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "literal",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = false,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },
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
                -- eslint = function()
                --     require("lazyvim.util").lsp.on_attach(function(client)
                --         if client.name == "eslint" then
                --             client.server_capabilities.documentFormattingProvider = true
                --         elseif client.name == "tsserver" then
                --             client.server_capabilities.documentFormattingProvider = false
                --         end
                --     end)
                -- end,
            },
        },
    }, -- configure html server   -- configure html server
}
