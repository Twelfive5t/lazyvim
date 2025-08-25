-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.encoding = "UTF-8" -- 默认编码格式为 "UTF-8"
vim.g.autoformat = false -- 默认关闭保存文件时自动格式化

local opt = vim.opt
opt.expandtab = true -- 使用空格代替 Tab 字符
opt.tabstop = 4 -- Tab 键显示为 4 个空格宽度
opt.shiftwidth = 4 -- 自动缩进宽度为 4 个空格
opt.softtabstop = 4 -- 编辑时 Tab 键等于 4 个空格
opt.relativenumber = false -- 是否显示相对行号
opt.listchars = "space:·" -- 不可见字符的显示，这里只把空格显示为一个点
vim.opt.listchars = {
  space = "·", -- 空格
--  eol = "$", -- 行尾符
  tab = ">-", -- 制表符
  trail = "·", -- 行尾空格
  lead = "·", -- 行首空格
  extends = "~", -- 超出屏幕右侧的文本
  precedes = "~", -- 超出屏幕左侧的文本
  conceal = "+", -- 被隐藏的字符
  nbsp = "&", -- 非断行空格
}
vim.g.snacks_scroll = false
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  callback = function()
    vim.fn.jobstart({ "im-select", "1033" }, { detach = true })
    vim.fn.jobstart({ "im-select", "2052" }, { detach = true })
  end,
})
