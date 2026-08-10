-- ============================================================================
-- vim-config.lua — core Vim behavior options
-- Location: ~/.dotfiles/config/nvim/lua/vim-config.lua
--           (loaded via require("vim-config") in init.lua;
--            ~/.config/nvim is a symlink into the dotfiles repo)
-- Reload after edits: restart nvim, or :source $MYVIMRC
-- ============================================================================

local o = vim.opt                -- shorthand alias: o.x is vim.opt.x

-- ---- Leader key ------------------------------------------------------------
-- The leader is the prefix for custom keybinds (<Space>f, <Space>g, ...).
-- It is a global variable, not an option, hence vim.g rather than vim.opt.
vim.g.mapleader = ' '            -- space is the leader key

-- ---- Indentation -----------------------------------------------------------
-- These three work together; keep shiftwidth and tabstop in agreement.
o.expandtab = true               -- pressing Tab inserts spaces, never a real tab
o.shiftwidth = 4                 -- 4 spaces per indent level (>> and auto-indent)
o.tabstop = 4                    -- render any literal tab character 4 wide

-- ---- Line numbers ----------------------------------------------------------
-- Together these give the hybrid display: the cursor line shows its ABSOLUTE
-- number; every other line shows its DISTANCE from the cursor.
-- Usage: a line showing "5" above the cursor -> 5k jumps to it. :42 jumps to
-- absolute line 42 regardless of the display.
-- o.number = true                  -- absolute number on the cursor line
o.relativenumber = true          -- relative numbers elsewhere, for fast jumps

-- ---- Search ----------------------------------------------------------------
o.ignorecase = true              -- searches are case-insensitive by default...
o.smartcase = true               -- ...unless the pattern contains a capital

-- ---- Clipboard -------------------------------------------------------------
-- Yank/paste use the system clipboard, so text moves freely between nvim and
-- other apps. Requires a clipboard provider on Linux: wl-clipboard (Wayland)
-- or xclip (X11) -- installed via configuration.nix.
o.clipboard = 'unnamedplus'      -- share the system clipboard

-- ---- Scrolling -------------------------------------------------------------
o.scrolloff = 16                 -- keep >=16 lines visible above/below the
                                 -- cursor, so context is never off-screen

-- ---- Undo ------------------------------------------------------------------
o.undofile = true                -- persist undo history to disk, so undo/redo
                                 -- survive closing and reopening a file
