-- ================================================================================================ "
-- @file     lua/core/options.lua
-- @brief    Neovim options migrated from .vimrc.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

local opt = vim.opt
local g = vim.g

-- ================================================================================================ "
-- leader key configuration
-- ================================================================================================ "
g.mapleader = ";"      -- define <Leader> key as semicolon
g.maplocalleader = ";" -- define <LocalLeader> key as semicolon

-- ================================================================================================ "
-- general editor behavior
-- ================================================================================================ "
opt.compatible = false                       -- set neovim running in nocompatible mode
opt.backspace = { "indent", "eol", "start" } -- allow backspacing over everything in insert mode
opt.autoindent = true                        -- turn on autoindent
opt.cindent = true                           -- turn on autoindent for C/C++
opt.cinoptions = "g-1"                       -- set cindent options: indent for multi-line statements
opt.backup = false                           -- turn off the backup file
opt.number = true                            -- turn on the line number
opt.history = 50                             -- set command line history with 50 lines
opt.ruler = true                             -- show the line and column number of the cursor position
opt.showcmd = true                           -- display incomplete commands at bottom right of the window
opt.hlsearch = true                          -- turn on searching highlight
opt.incsearch = true                         -- turn on incremental searching
opt.wrap = false                             -- turn off the line wrap while exceed window width
opt.langmenu = "none"                        -- set vim menu language to default
opt.expandtab = true                         -- use spaces while press <Tab> key in insert mode
opt.tabstop = 4                              -- set tab size to 4 spaces
opt.shiftwidth = 4                           -- set indent size to 4 spaces
opt.showmatch = true                         -- turn on matching brackets jumping
opt.wildmenu = true                          -- turn on enhanced built-in command-line completion
opt.swapfile = false                         -- turn off the swap file
opt.foldenable = false                       -- not fold any text while file was opened
opt.ignorecase = true                        -- set case-insensitive in search patterns
opt.smartcase = true                         -- turn on case-sensitive while upper case exist in search patterns
opt.mouse = "nv"                             -- enable mouse support in normal and visual mode
opt.tags = "tags;"                           -- specify tags searching path upward to root(/)
opt.shortmess:append("atToOc")               -- set short message types (include 'c' for no ins-completion-menu msgs)
opt.modeline = true                          -- enable vim modeline
opt.modelines = 5                            -- set the count of valid vim modelines
opt.textwidth = 100                          -- set maximum textwidth for break lines automatically
opt.formatoptions:append("t")                -- set automatically wrap text using textwidth
opt.colorcolumn = "100"                      -- highlighting 100th column for auxiliary
opt.laststatus = 2                           -- set windows always have the status line
opt.showmode = false                         -- do not show Insert/Replace/Visual mode on the last line
opt.cursorline = true                        -- highlight the text line of the cursor
opt.list = true                              -- enable list mode
opt.updatetime = 500                         -- set update time to 500ms

-- ================================================================================================ "
-- set characters to show in list mode
-- ================================================================================================ "
opt.listchars = {
    tab = "▸-",
    trail = "•",
    precedes = "«",
    extends = "»",
    eol = "↲",
    nbsp = "␣",
}

-- ================================================================================================ "
-- auto-complete properties in insert mode
-- ================================================================================================ "
opt.completeopt = { "menu", "menuone", "preview", "noselect" }

-- ================================================================================================ "
-- character encoding settings
-- ================================================================================================ "
opt.encoding = "utf-8"     -- set encoding for neovim internal use
opt.fileencoding = "utf-8" -- set encoding for new file
opt.fileencodings = "ucs-bom,utf-8,default,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

-- ================================================================================================ "
-- sign column and built-in plugin settings
-- ================================================================================================ "
opt.signcolumn = "auto" -- set signcolumn draw mode to auto

-- disable built-in netrw to let nvim-tree take over file explorer
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
