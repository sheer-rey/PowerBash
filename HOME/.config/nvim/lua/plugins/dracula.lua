-- ================================================================================================ "
-- @file     lua/plugins/dracula.lua
-- @brief    Dracula colorscheme with custom highlight overrides.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "Mofiqul/dracula.nvim",
    lazy = false,    -- load during startup
    priority = 1000, -- ensure it loads before other plugins
    config = function()
        -- setup dracula colorscheme
        require("dracula").setup({
            transparent_bg = false,
        })
        vim.cmd.colorscheme("dracula")

        -- re-define some highlight rules to match original cterm settings
        local hl = vim.api.nvim_set_hl
        hl(0, "Normal", { fg = "#eeeeee", bg = "#262626" })
        hl(0, "Comment", { fg = "#808080", bg = "#262626" })
        hl(0, "ColorColumn", { bg = "#444444" })
    end,
}
