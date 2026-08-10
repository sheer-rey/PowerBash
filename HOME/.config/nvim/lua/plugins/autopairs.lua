-- ================================================================================================ "
-- @file     lua/plugins/autopairs.lua
-- @brief    Auto close brackets and quotes replacing auto-pairs.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- load only when entering insert mode
    config = function()
        require("nvim-autopairs").setup({
            check_ts = true, -- use treesitter to avoid pairing inside strings/comments
        })
    end,
}
