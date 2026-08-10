-- ================================================================================================ "
-- @file     lua/core/autocmds.lua
-- @brief    Autocommands migrated from .vimrc.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ================================================================================================ "
-- let cursor return to the position before the file closed when it's reopened
-- ================================================================================================ "
autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    pattern = "*",
    callback = function()
        local line = vim.fn.line("'\"")
        if line > 0 and line <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
            vim.cmd('normal! g`"')
        end
    end,
})

-- ================================================================================================ "
-- do not hidden concealed text while filetype is markdown
-- ================================================================================================ "
autocmd("BufEnter", {
    group = augroup("MarkdownConceal", { clear = true }),
    pattern = "*.md",
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

-- ================================================================================================ "
-- set commentstring to '// ' for c/c++ files
-- ================================================================================================ "
autocmd("FileType", {
    group = augroup("CppComment", { clear = true }),
    pattern = { "c", "cpp" },
    callback = function()
        vim.bo.commentstring = "// %s"
    end,
})

-- ================================================================================================ "
-- do not expand tab to spaces while filetype is Makefile
-- ================================================================================================ "
autocmd("FileType", {
    group = augroup("MakefileTab", { clear = true }),
    pattern = "make",
    callback = function()
        vim.opt_local.expandtab = false
    end,
})

-- ================================================================================================ "
-- highlight yanked text briefly for visual feedback
-- ================================================================================================ "
autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})
