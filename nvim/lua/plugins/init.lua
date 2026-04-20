return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- nvim 0.11 backwards compatibility
    opts = {
      ensure_installed = {
        "hyprlang", "vim", "lua", "vimdoc",
        "html", "css", "c_sharp", "razor", "rust", "toml"
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      }
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "lua-language-server", "xmlformatter", "csharpier", "prettier",
        "stylua", "bicep-lsp", "html-lsp", "css-lsp", "eslint-lsp",
        "typescript-language-server", "json-lsp", "rust-analyzer", "roslyn",
        "bacon", "bacon-ls", "taplo",
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {},
    lazy = false,
  },
   {
    'ramboe/ramboe-dotnet-utils',
    dependencies = { 'mfussenegger/nvim-dap' }
  },
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      require "configs.nvim-dap"
    end,
  },
  {
    "igorlfs/nvim-dap-view",
    lazy = false,
    version = "1.*",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapview = require("dap-view")
      dapview.setup()
      dap.listeners.after.event_initialized["dapview_config"] = function()
        dapview.open()
      end
      dap.listeners.before.event_terminated["dapview_config"] = function()
        dapview.close()
      end
      dap.listeners.before.event_exited["dapview_config"] = function()
        dapview.close()
      end
    end,
  },
  { "nvim-neotest/nvim-nio" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "Issafalcon/neotest-dotnet",
    lazy = false,
    dependencies = { "nvim-neotest/neotest" },
  },
}