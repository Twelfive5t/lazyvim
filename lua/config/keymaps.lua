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
