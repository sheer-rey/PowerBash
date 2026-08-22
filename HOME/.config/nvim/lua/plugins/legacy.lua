-- ================================================================================================ "
-- @file     lua/plugins/legacy.lua
-- @brief    Legacy vim plugins kept for compatibility.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    -- a.vim: alternate between .c/.h files
    {
        "vim-scripts/a.vim",
        keys = {
            { "<leader>a", ":A<CR>", desc = "Switch header/source" },
        },
    },

    -- vim-cppman: C++ manual lookup
    {
        "aitjcize/cppman",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp" },
                callback = function(args)
                    if args.match == "c" then
                        vim.bo.keywordprg = ":Cppman!" -- search c standard library
                    else
                        vim.bo.keywordprg = ":Cppman"  -- search c++ standard library
                    end
                end,
            })
        end,
    },
}
