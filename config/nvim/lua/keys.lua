vim.keymap.set("n", "<Esc>", "<cmd>write<cr>", { silent = true }) -- autosave by pressing Esc
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })     -- select all 
vim.keymap.set("x", "p", '"_dP')                                  -- pasting over selection without losing clipboard
