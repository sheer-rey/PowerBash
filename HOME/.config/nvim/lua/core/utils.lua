-- ================================================================================================ "
-- @file     lua/core/utils.lua
-- @brief    Utility functions migrated from .vimrc.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

local M = {}

-- ================================================================================================ "
-- support yank to remote terminal via osc52 escape sequence
-- ================================================================================================ "
function M.osc_yank()
    -- get content of default register and normalize line endings
    local text = vim.fn.getreg('"')
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    if text == "" then
        return
    end

    -- generate osc52 sequence by external osc_yank tool
    local escaped = vim.fn.shellescape(text):gsub("\\\n", "\n")
    local cmd = "echo " .. escaped .. " | osc_yank"
    local seq = vim.fn.system(cmd)

    -- write sequence to stderr if available
    if vim.fn.filewritable("/dev/fd/2") == 1 then
        vim.fn.writefile({ seq }, "/dev/fd/2", "b")
    end
end

return M
