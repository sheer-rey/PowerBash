-- ================================================================================================ "
-- @file     init.lua
-- @brief    Neovim configuration entry point.
--
-- @author   sheer.rey <sheer.rey@gmail.com>
-- @date     08/10/2026
-- @version  0.1.0
-- ================================================================================================ "

-- ================================================================================================ "
-- load core configuration modules
-- ================================================================================================ "
require("core.options")  -- editor options migrated from .vimrc
require("core.keymaps")  -- key mappings migrated from .vimrc
require("core.autocmds") -- autocommands migrated from .vimrc
require("core.utils")    -- utility functions migrated from .vimrc

-- ================================================================================================ "
-- load plugin manager and all plugin specifications
-- ================================================================================================ "
require("plugins")
