-- ================================================================================================ "
-- @file     lua/plugins/gitsigns.lua
-- @brief    Git integration replacing vim-gitgutter and vim-gitbranch.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- git hunk navigation and operations
                map("n", "]c", gs.next_hunk)
                map("n", "[c", gs.prev_hunk)
                map("n", "<leader>hs", gs.stage_hunk)
                map("n", "<leader>hr", gs.reset_hunk)
                map("n", "<leader>hp", gs.preview_hunk)
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end)
            end,
        })
    end,
}
