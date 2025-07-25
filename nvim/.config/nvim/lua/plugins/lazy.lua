-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end --@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure `lazy.nvim` and install plugins ]]
require('lazy').setup({
  spec = {
    { import = 'plugins.themes' },
    { import = 'plugins.ui' },
    { import = 'plugins.lang' },
    { import = 'plugins.utils' },
  },
})

-- [[ load keymaps ]]
require('core.utils').setup_keymaps('lazy')
