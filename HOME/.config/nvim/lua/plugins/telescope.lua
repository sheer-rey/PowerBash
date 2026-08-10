-- ================================================================================================ "
-- @file     lua/plugins/telescope.lua
-- @brief    Fuzzy finder replacing LeaderF/CtrlP.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
        { "<leader>ff",  "<cmd>Telescope find_files<CR>",            desc = "Find files" },
        { "<leader>fb",  "<cmd>Telescope buffers<CR>",               desc = "Find buffers" },
        { "<leader>fm",  "<cmd>Telescope lsp_document_symbols<CR>",  desc = "Document symbols" },
        { "<leader>fam", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
        { "<leader>fr",  "<cmd>Telescope live_grep<CR>",             desc = "Live grep" },
        { "<C-p>",       "<cmd>Telescope find_files<CR>",            desc = "Find files" },
    },
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        -- custom navigation keys matching original LeaderF behavior
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-p>"] = actions.move_selection_previous,
                        ["<C-n>"] = actions.move_selection_next,
                    },
                },
            },
            pickers = {
                find_files = {
                    hidden = true, -- include hidden files in search
                },
            },
        })
        -- load fzf extension for better performance
        require("telescope").load_extension("fzf")
    end,
}
