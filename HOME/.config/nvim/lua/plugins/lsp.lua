-- ================================================================================================ "
-- @file     lua/plugins/lsp.lua
-- @brief    Language Server Protocol configuration using native vim.lsp api.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",           -- lsp server installer
        "williamboman/mason-lspconfig.nvim", -- bridge between mason and lspconfig
        "hrsh7th/cmp-nvim-lsp",              -- lsp completion source
    },
    config = function()
        -- setup mason package manager
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "clangd",  -- c/c++ language server
                "pyright", -- python language server
                "gopls",   -- go language server
                "bashls",  -- bash language server
                "lua_ls",  -- lua language server
            },
            automatic_installation = true,
        })

        -- default capabilities for all lsp servers (includes nvim-cmp support)
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- use vim.lsp.config for neovim 0.11+ compatibility
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- define per-server configurations
        local servers = {
            clangd = {},
            pyright = {},
            gopls = {},
            bashls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                    },
                },
            },
        }

        -- enable each lsp server
        for server, config in pairs(servers) do
            vim.lsp.config(server, config)
            vim.lsp.enable(server)
        end

        -- common lsp keymaps applied when a language server attaches to buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = function(args)
                local bufnr = args.buf
                local bufmap = function(mode, lhs, rhs)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
                end

                bufmap("n", "gd", vim.lsp.buf.definition)
                bufmap("n", "gD", vim.lsp.buf.declaration)
                bufmap("n", "gr", vim.lsp.buf.references)
                bufmap("n", "gi", vim.lsp.buf.implementation)
                bufmap("n", "K", vim.lsp.buf.hover)
                bufmap("n", "<leader>rn", vim.lsp.buf.rename)
                bufmap("n", "<leader>ca", vim.lsp.buf.code_action)
                bufmap("n", "[d", vim.diagnostic.goto_prev)
                bufmap("n", "]d", vim.diagnostic.goto_next)
                bufmap("n", "<leader>e", vim.diagnostic.open_float)
            end,
        })
    end,
}
