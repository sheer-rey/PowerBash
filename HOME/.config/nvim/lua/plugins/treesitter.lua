-- ================================================================================================ "
-- @file     lua/plugins/treesitter.lua
-- @brief    Syntax highlighting and code parsing replacing vim-polyglot.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- use main branch for neovim 0.12+ compatibility
    build = ":TSUpdate",
    dependencies = {
        "HiPhish/rainbow-delimiters.nvim", -- rainbow parentheses based on treesitter
    },
    config = function()
        -- nvim-treesitter main branch uses direct setup api
        require("nvim-treesitter").setup({
            ensure_installed = {
                "c",
                "cpp",
                "python",
                "go",
                "bash",
                "lua",
                "vim",
                "vimdoc",
                "markdown",
            },
            auto_install = false, -- do not auto install missing parsers
            highlight = { enable = true },
            indent = { enable = true },
        })

        -- incremental selection keymaps using native treesitter api
        vim.keymap.set("n", "gnn", function()
            require("nvim-treesitter.incremental_selection").init_selection()
        end, { silent = true })
        vim.keymap.set({ "n", "x", "o" }, "grn", function()
            require("nvim-treesitter.incremental_selection").node_incremental()
        end, { silent = true })
        vim.keymap.set({ "n", "x", "o" }, "grc", function()
            require("nvim-treesitter.incremental_selection").scope_incremental()
        end, { silent = true })
        vim.keymap.set({ "n", "x", "o" }, "grm", function()
            require("nvim-treesitter.incremental_selection").node_decremental()
        end, { silent = true })
    end,
}
