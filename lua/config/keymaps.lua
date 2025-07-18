-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
for _, mode in pairs({ "i", "v", "n" }) do
  vim.keymap.del(mode, "<A-j>")
  vim.keymap.del(mode, "<A-k>")
end
-- Alt+j 跳转到下一个修改点（与 ]h 等效）
vim.keymap.set("n", "<A-j>", "]h", { desc = "下一个修改点" })
-- 可选：Alt+k 跳转到上一个修改点
vim.keymap.set("n", "<A-k>", "[h", { desc = "上一个修改点" })
-- Insert 模式下 Alt + hjkl → 移动光标（←↓↑→）
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "← 左移光标" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "↓ 下移光标" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "↑ 上移光标" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "→ 右移光标" })
-- Insert 模式下 Alt + w/e/b → 单词移动（和 normal 模式一致）
vim.keymap.set("i", "<A-w>", "<C-o>w", { desc = "→ 向后跳到下个词首" })
vim.keymap.set("i", "<A-e>", "<C-o>e", { desc = "→ 向后跳到下个词尾" })
vim.keymap.set("i", "<A-b>", "<C-o>b", { desc = "← 向前跳到前一个词首" })
