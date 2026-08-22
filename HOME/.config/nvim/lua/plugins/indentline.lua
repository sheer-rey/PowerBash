-- ================================================================================================ "
-- @file     lua/plugins/indentline.lua
-- @brief    Indent guide lines replacing indentline.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
        require("ibl").setup({
            scope = { enabled = true }, -- highlight current scope
        })
    end,
}
