require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust_analyzer" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 

-- ROSLYN (+razor support)
local mason_root = require("mason.settings").current.install_root_dir
vim.lsp.config("roslyn", {})
