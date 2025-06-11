-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("onedarkpro").setup({
        -- 一定要放到 options 里
        options = {
          style            = "darker",      -- 选择 darker 而不是默认的 dark
          transparent      = false,         -- 旧版的 transparent_mode
          term_colors      = false,         -- 是否设置终端色彩
        },

        -- 针对 darker 风格仅覆盖背景色
        colors = {
          darker = { bg = "#23272e" },
        },

        -- 直接覆盖调色盘，保留其他色阶
        palette_overrides = {
          darker0   = "#23272e",   -- 覆盖 darker 模式下的第一层背景
          dark0     = "#23272e",   -- 以防还有地方在用 dark0
          bg1       = "#1e2227",
          bg2       = "#23272e",
          bg3       = "#2c313c",
          fg        = "#abb2bf",
          grey      = "#495162",
          comment   = "#5c6370",
          blue      = "#528bff",
          light_blue= "#61afef",
          cyan      = "#56b6c2",
          green     = "#98c379",
          orange    = "#d19a66",
          purple    = "#c678dd",
          red       = "#e06c75",
          yellow    = "#e5c07b",
        },

        highlights = {
          Normal       = { bg = "#23272e" },
          NormalNC     = { bg = "#23272e" },
          Visual       = { bg = "#677696" },
          CursorLine   = { bg = "#2c313c" },
          CursorLineNr = { fg = "#abb2bf", style = "bold" },
          LineNr       = { fg = "#495162" },
          Search       = { bg = "#ffffff", fg = "#000000" },
          IncSearch    = { bg = "#d19a66" },

          Pmenu        = { bg = "#1e2227", fg = "#abb2bf" },
          PmenuSel     = { bg = "#2c313a", fg = "#ffffff" },
          PmenuThumb   = { bg = "#747d91" },

          FloatBorder  = { fg = "#181a1f" },
          NormalFloat  = { bg = "#1e2227" },

          TabLine      = { bg = "#1e2227", fg = "#9da5b4" },
          TabLineFill  = { bg = "#181a1f" },
          TabLineSel   = { bg = "#23272e", fg = "#dcdcdc", style = "bold" },

          StatusLine   = { bg = "#1e2227", fg = "#9da5b4" },
          StatusLineNC = { bg = "#1e2227", fg = "#6b717d" },

          TelescopeBorder      = { fg = "#3e4452" },
          TelescopePrompt      = { bg = "#1e2227" },
          TelescopePromptTitle = { fg = "#abb2bf", bg = "#404754" },
          TelescopePromptPrefix= { fg = "#4d78cc" },
          TelescopeResultsTitle= { fg = "#abb2bf", bg = "#21252b" },
          TelescopePreviewTitle= { fg = "#abb2bf", bg = "#21252b" },

          TerminalBlack   = { fg = "#3f4451" },
          TerminalRed     = { fg = "#e05561" },
          TerminalGreen   = { fg = "#8cc265" },
          TerminalYellow  = { fg = "#d18f52" },
          TerminalBlue    = { fg = "#4aa5f0" },
          TerminalMagenta = { fg = "#c162de" },
          TerminalCyan    = { fg = "#42b3c2" },
          TerminalWhite   = { fg = "#d7dae0" },

          Comment      = { fg = "#5c6370", style = "italic" },
          Keyword      = { fg = "#c678dd", style = "bold" },
          StorageClass = { fg = "#c678dd" },
          Function     = { fg = "#61afef" },
          String       = { fg = "#98c379" },
          Number       = { fg = "#d19a66" },
          Type         = { fg = "#e5c07b" },
          Identifier   = { fg = "#e06c75" },
          Operator     = { fg = "#56b6c2" },
          Boolean      = { fg = "#56b6c2" },
          Property     = { fg = "#e5c07b" },
          Tag          = { fg = "#e06c75" },
        },
      })

      vim.cmd.colorscheme("onedark")
    end,
  },
}
