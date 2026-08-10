-- ================================================================================================ "
-- @file     lua/core/keymaps.lua
-- @brief    Key mappings migrated from .vimrc.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ================================================================================================ "
-- window navigation mappings
-- ================================================================================================ "
map("n", "<leader>h", "<C-w>h", opts) -- jump to the window left
map("n", "<leader>l", "<C-w>l", opts) -- jump to the window right
map("n", "<leader>k", "<C-w>k", opts) -- jump to the window above
map("n", "<leader>j", "<C-w>j", opts) -- jump to the window below

-- ================================================================================================ "
-- split window and explore mappings
-- ================================================================================================ "
map("n", "<leader>s", ":Sexplore<CR>", opts) -- split current window and explore current file's directory
map("n", "<leader>v", ":Vexplore<CR>", opts) -- vertical split current window and explore current file's directory

-- ================================================================================================ "
-- quickfix window mappings
-- ================================================================================================ "
map("n", "<leader>co", ":copen<CR>", opts)  -- open quickfix window
map("n", "<leader>cc", ":cclose<CR>", opts) -- close quickfix window
map("n", "<leader>cn", ":cnext<CR>", opts)  -- jump to next result of quickfix window
map("n", "<leader>cp", ":cprev<CR>", opts)  -- jump to previous result of quickfix window
map("n", "<leader>cl", ":clist<CR>", opts)  -- show result list in quickfix window

-- ================================================================================================ "
-- plugin-independent mappings
-- ================================================================================================ "
map("n", "<leader>a", ":A<CR>", opts)                                    -- switch between header and source file (a.vim)
map("n", "<leader>y", ":lua require('core.utils').osc_yank()<CR>", opts) -- yank to remote terminal via osc52
