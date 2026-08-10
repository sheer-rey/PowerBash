-- ================================================================================================ "
-- @file     lua/plugins/comment.lua
-- @brief    Comment helper replacing vim-commentary.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

return {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup()
        -- gcc: toggle line comment
        -- gc: toggle comment for selection/motion
        -- gb: toggle block comment
    end,
}
