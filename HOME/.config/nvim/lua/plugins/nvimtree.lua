-- ================================================================================================ "
-- @file     lua/plugins/nvimtree.lua
-- @brief    File explorer replacing NERDTree.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>n", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                side = "left", -- set file tree window position to left
                width = 30,
            },
            renderer = {
                group_empty = true,   -- group empty directories
                highlight_git = true, -- highlight git status
                icons = {
                    show = {
                        git = true,
                    },
                    glyphs = {
                        -- custom git status indicators matching original NERDTree style
                        git = {
                            unstaged = "~",
                            staged = "+",
                            unmerged = "!",
                            renamed = "→",
                            untracked = "«",
                            deleted = "x",
                            ignored = "…",
                        },
                    },
                },
            },
            filters = {
                dotfiles = false, -- show hidden files
            },
            actions = {
                open_file = {
                    quit_on_open = false,
                },
            },
        })

        -- close the tab if NvimTree is the only window remaining in it
        vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("NvimTreeAutoClose", { clear = true }),
            nested = true,
            callback = function()
                local api = require("nvim-tree.api")
                if #vim.api.nvim_list_wins() == 1 and api.tree.is_tree_buf() then
                    vim.cmd("quit")
                end
            end,
        })
    end,
}
