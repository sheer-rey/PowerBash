-- ================================================================================================ "
-- @file     lua/plugins/bufferline.lua
-- @brief    Buffer tab line replacing minibufexpl.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",         -- show open buffers as tabs
                diagnostics = "nvim_lsp", -- show lsp diagnostics on tabs
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        })
    end,
}
