require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- When Neovim opens, send an OSC escape sequence to WezTerm
-- setting the NVIM user variable to "1" (MQ== is base64 for "1")
-- WezTerm listens for this and removes window padding
autocmd("VimEnter", {
  callback = function()
    io.write("\x1b]1337;SetUserVar=NVIM=MQ==\x07")
    io.flush()
  end,
})

-- When Neovim closes, set the NVIM user variable to "0" (MA== is base64 for "0")
-- WezTerm listens for this and restores window padding
autocmd("VimLeavePre", {
  callback = function()
    io.write("\x1b]1337;SetUserVar=NVIM=MA==\x07")
    io.flush()
  end,
})

