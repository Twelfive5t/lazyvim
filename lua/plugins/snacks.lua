return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,  -- 显示隐藏文件
      ignored = true, -- 显示被 .gitignore 忽略的文件
      sources = {
        -- <space><space> 搜索文件时
        files = {
          hidden = true,    -- 显示隐藏文件
          ignored = true,  -- 显示被 .gitignore 忽略的文件
        },
        -- <leader>fe 或 <space>e 打开侧边栏时
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
