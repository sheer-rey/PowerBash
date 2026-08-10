-- ================================================================================================ "
-- @file     lua/plugins/lualine.lua
-- @brief    Status line configuration migrated from lightline.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("lualine").setup({
            options = {
                theme = "dracula",   -- use dracula theme to match colorscheme
                globalstatus = true, -- single global status line
            },
            sections = {
                lualine_a = { "mode", "paste" },
                lualine_b = {
                    "branch",      -- git branch name
                    "diff",        -- git diff summary
                    "diagnostics", -- lsp diagnostic counts
                },
                lualine_c = { "filename", "readonly", "modified" },
                lualine_x = { "fileformat", "fileencoding", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        })
    end,
}
