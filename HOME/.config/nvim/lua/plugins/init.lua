-- ================================================================================================ "
-- @file     lua/plugins/init.lua
-- @brief    lazy.nvim bootstrap and plugin specifications.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

-- ================================================================================================ "
-- bootstrap lazy.nvim plugin manager if not installed
-- ================================================================================================ "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ================================================================================================ "
-- setup lazy.nvim and import all plugin specifications
-- ================================================================================================ "
require("lazy").setup({
    { import = "plugins.dracula" },        -- colorscheme
    { import = "plugins.lualine" },        -- status line
    { import = "plugins.bufferline" },     -- buffer tabs
    { import = "plugins.nvimtree" },       -- file explorer
    { import = "plugins.telescope" },      -- fuzzy finder
    { import = "plugins.treesitter" },     -- syntax highlighting
    { import = "plugins.lsp" },            -- language server protocol
    { import = "plugins.cmp" },            -- auto completion
    { import = "plugins.gitsigns" },       -- git integration
    { import = "plugins.indentline" },     -- indent guides
    { import = "plugins.autopairs" },      -- auto close brackets
    { import = "plugins.comment" },        -- comment helper
    { import = "plugins.aerial" },         -- symbol outline
    { import = "plugins.legacy" },         -- vim plugins kept for compatibility
}, {
    checker = { enabled = false },         -- disable automatic plugin update checks
    change_detection = { notify = false }, -- do not notify on config file changes
})
