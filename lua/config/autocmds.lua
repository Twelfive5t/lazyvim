-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local im_select = vim.fn.executable("im-select") == 1 and "im-select"
  or vim.fn.executable("im-select.exe") == 1 and "im-select.exe"
  or nil

if im_select then
  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    callback = function()
      vim.fn.jobstart({ im_select, "1033" }, {
        on_exit = function()
          vim.schedule(function()
            vim.fn.jobstart({ im_select, "2052" }, {
              detach = true,
            })
          end)
        end,
      })
    end,
  })
end
