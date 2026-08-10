-- ================================================================================================ "
-- @file     lua/plugins/aerial.lua
-- @brief    Symbol outline window replacing taglist.vim.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "stevearc/aerial.nvim",
    keys = {
        { "<leader>m", "<cmd>AerialToggle!<CR>", desc = "Toggle symbol outline" },
    },
    config = function()
        require("aerial").setup({
            backends = { "lsp", "treesitter", "markdown" },
            layout = {
                default_direction = "right", -- place outline on the right side
            },
        })
    end,
}
