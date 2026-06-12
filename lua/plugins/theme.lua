-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("onedarkpro").setup({
        colors = {
          bg = "#16191d",
          fg = "#abb2bf",
          red = "#e06c75",
          orange = "#d19a66",
          yellow = "#e5c07b",
          green = "#98c379",
          cyan = "#56b6c2",
          blue = "#61afef",
          purple = "#c678dd",
          black = "#16191d",
          comment = "#7f848e",

          float_bg = "#16191d",
          cursorline = "#2c313c",
          color_column = "#2c313c",
          line_number = "#667187",
          selection = "#353c4a",
        },
        highlights = {
          Normal = { bg = "#16191d" },
          NormalNC = { bg = "#16191d" },
          Cursor = { fg = "#16191d", bg = "#ffb3c1" },
          lCursor = { fg = "#16191d", bg = "#ffb3c1" },
          CursorIM = { fg = "#16191d", bg = "#ffb3c1" },
          CursorLine = { bg = "#2c313c" },
          CursorLineNr = { fg = "#abb2bf", bg = "#2c313c", bold = true },
          LineNr = { fg = "#667187" },
          Visual = { bg = "#353c4a" },
          Search = { bg = "#4c3c2f" },
          IncSearch = { fg = "#16191d", bg = "#d19a66" },
          Comment = { fg = "#7f848e" },
          TermCursor = { bg = "#ffb3c1" },
          TermCursorNC = { bg = "#ffb3c1" },
        },
        options = {
          style = "darker",
          transparency = false,
          terminal_colors = true,
        },
      })

      vim.cmd.colorscheme("onedark")
      -- 光标颜色见 https://neovim.cn/doc/user/faq.html
      vim.opt.guicursor = {
        "n-v-c-sm:block-Cursor/lCursor",
        "i-ci-ve:ver25-Cursor/lCursor",
        "r-cr-o:hor20-Cursor/lCursor",
        "t:block-blinkon500-blinkoff500-TermCursor",
      }
    end,
  },
}
