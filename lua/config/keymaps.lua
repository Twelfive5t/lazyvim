-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Alt+j 跳转到下一个修改点（与 ]h 等效）
vim.keymap.set("n", "<A-j>", function()
  local gs = package.loaded.gitsigns
  if not gs then return end

  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    gs.nav_hunk("next")
  end
end, { desc = "Next Hunk" })

-- 可选：Alt+k 跳转到上一个修改点
vim.keymap.set("n", "<A-k>", function()
  local gs = package.loaded.gitsigns
  if not gs then return end

  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    gs.nav_hunk("prev")
  end
end, { desc = "Prev Hunk" })

-- Insert 模式下 Alt + w/e/b → 单词移动（和 normal 模式一致）
vim.keymap.set("i", "<A-w>", "<C-o>w", { desc = "→ 向后跳到下个词首" })
vim.keymap.set("i", "<A-e>", "<C-o>e", { desc = "→ 向后跳到下个词尾" })
vim.keymap.set("i", "<A-b>", "<C-o>b", { desc = "← 向前跳到前一个词首" })

-- Insert 模式：ESC 后光标右移一位
vim.keymap.set("i", "<Esc>", "<Esc>l", { desc = "退出插入并右移一位" })

-- Shift + PageUp / PageDown → 调整 buffer 顺序（基于 bufferline）
vim.keymap.set("n", "<S-PageUp>", "<cmd>BufferLineMovePrev<cr>", { desc = "Buffer 左移" })
vim.keymap.set("n", "<S-PageDown>", "<cmd>BufferLineMoveNext<cr>", { desc = "Buffer 右移" })

-- -- Shift + j / k → 快速移动 5 行（n + v 模式）
-- vim.keymap.set({ "n", "v" }, "J", "5j", { desc = "下移 5 行" })
-- vim.keymap.set({ "n", "v" }, "K", "5k", { desc = "上移 5 行" })

-- d / x 使用黑洞寄存器（n + v 模式）
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "删除（黑洞寄存器）" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "删除字符（黑洞寄存器）" })

-- gg 到首行第一个非空字符
vim.keymap.set("n", "gg", "gg^", { desc = "跳到首行第一个非空字符" })
