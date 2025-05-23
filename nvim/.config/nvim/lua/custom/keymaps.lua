--  NOTE: See `:help vim.keymap.set()`

--[[
--    Basic idea of keymap design:
--    1. all the usr configure functions and utils: "<leader>..."
--    2. window and buffer navigation: "<C->"
--      move-window: <C-hjkl>
--      move-buffer: <C-[]>
--      delete_window: "<leader>wd"
--      delete-buffer: "<leader>bd"
--      zoom: <C-z>
--    3. change window layout(such as term toggle): ";..."
--      split: ";-" and ";\"
--      toggle_in_split: ";<lowerCaseLetter>"
--      toggle_in_float: ";<UpperCaseLetter>"
--]]
local M = {}

-- set a function to configure keymaps
local function kmap(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- NOTE: lsp commands(<leader>l)
function M.lsp(event)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, {
      buffer = event.buf, -- Critical for buffer-local mappings
      desc = 'LSP: ' .. desc,
    })
  end
  kmap('n', '<leader>ll', vim.diagnostic.setloclist, { desc = 'Open [l]sp diagnostic quickfix [l]ist' })
  map('<leader>lm', function()
    vim.diagnostic.open_float()
  end, 'show diag [m]essage')
  map('<leader>ld', require('telescope.builtin').lsp_definitions, '[d]efinition') --  To jump back, press <C-t>.
  map('<leader>lp', require('goto-preview').goto_preview_definition, '[p]review definition')
  map('<leader>lr', require('telescope.builtin').lsp_references, '[r]eferences')
  map('<leader>lI', require('telescope.builtin').lsp_implementations, '[I]mplementation')
  map('<leader>lt', require('telescope.builtin').lsp_type_definitions, '[t]ype definition')
  map('<leader>ls', require('telescope.builtin').lsp_document_symbols, 'document [s]ymbols')
  map('<leader>lS', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'workspace [S]ymbols')
  map('<leader>lR', vim.lsp.buf.rename, '[R]eame')
  map('<leader>la', vim.lsp.buf.code_action, 'code [A]ction', { 'n', 'x' })
  map('<leader>lD', vim.lsp.buf.declaration, '[D]eclaration')
end

function M.hop()
  -- Improved native jumping using hop.nvim
  local hop = require 'hop'
  kmap({ 'n', 'v' }, 'f', function()
    hop.hint_char1 {
      direction = require('hop.hint').HintDirection.AFTER_CURSOR,
      current_line_only = false,
    }
  end, { desc = 'hop forward', remap = true })
  kmap({ 'n', 'v' }, 'F', function()
    hop.hint_char1 {
      direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
      current_line_only = false,
    }
  end, { desc = 'hop backward', remap = true })
  kmap('n', 's', function()
    hop.hint_char1()
  end, { desc = 'Hop to character' })
  kmap('n', 'S', function()
    hop.hint_words()
  end, { desc = 'Hop to word' })
end

-- NOTE: buffer operation (C to navigate, <leader>b to operate)
function M.bufferline()
  -- plugin: bufferline
  kmap('n', '<C-[>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })
  kmap('n', '<C-]>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
  kmap('n', '<leader>bh', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move buffer prev' })
  kmap('n', '<leader>bl', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move buffer next' })
  kmap('n', '<leader>bd', ':bdelete<CR>', { desc = '[D]elete buffer' })
end

-- NOTE: code folding
function M.ufo()
  -- plugin: ufo
  kmap('n', '<leader>O', require('ufo').openAllFolds, { desc = 'open all folds' })
  kmap('n', '<leader>F', require('ufo').closeAllFolds, { desc = 'close all folds' })
  kmap('n', '<leader>o', 'zO', { desc = 'open current fold' })
  kmap('n', '<leader>f', 'zC', { desc = 'close current fold' })
end

-- NOTE: auto format
function M.format()
  kmap('n', '<leader>cf', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[c]ode [f]ormat buffer' })
end

-- NOTE: terminal (<leader>t)
function M.terminal()
  local Snacks = require 'snacks'
  kmap('n', '<leader>tt', function()
    Snacks.terminal.toggle(nil, {
      cwd = vim.fn.expand '%:p:h',
      start_insert = false,
      auto_insert = false,
      auto_close = true,
    })
  end, { desc = 'Toggle terminal (current dir)' })
  kmap('n', '<leader>tT', function()
    Snacks.terminal.toggle(nil, {
      cwd = vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd(),
      start_insert = false,
      auto_insert = false,
      auto_close = true,
    })
  end, { desc = 'Toggle terminal (workspace root)' })
end

-- NOTE: search and goto (<leader>s, <leader>g)
function M.telescope()
  -- plugin telescope
  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  kmap('n', '<leader>gf', builtin.find_files, { desc = '[g]oto [f]iles' })
  kmap('n', '<leader>g.', builtin.oldfiles, { desc = '[g]oto Recent Files ("." for repeat)' })
  kmap('n', '<leader>gb', builtin.buffers, { desc = '[g]oto existing [b]uffers' })
  -- kmap('n', '<leader>ss', builtin.builtin, { desc = '[s]earch [s]elect Telescope' })
  kmap('n', '<leader>sw', builtin.grep_string, { desc = '[s]earch current [w]ord' })
  kmap('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
  kmap('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
  kmap('n', '<leader>sa', builtin.live_grep, { desc = '[s]earch [a]ll workspace by grep' })
  kmap('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [d]iagnostics' })
  kmap('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
  vim.keymap.set('n', '<leader>sb', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[s]earch in current [b]uffer fuzzily' })
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set('n', '<leader>so', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[s]earch in [o]pen Files by grep' })
  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>gn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[g]oto [n]eovim files' })
end

-- NOTE:  nvim-dap (<leader>d)
function M.dap()
  local dap = require 'dap'
  kmap('n', '<leader>ds', dap.continue, { desc = ' Start/Continue' })
  kmap('n', '<F1>', dap.continue, { desc = ' Start/Continue' })
  kmap('n', '<leader>di', dap.step_into, { desc = ' Step into' })
  kmap('n', '<F2>', dap.step_into, { desc = ' Step into' })
  kmap('n', '<leader>do', dap.step_over, { desc = ' Step over' })
  kmap('n', '<F3>', dap.step_over, { desc = ' Step over' })
  kmap('n', '<leader>dO', dap.step_out, { desc = ' Step out' })
  kmap('n', '<F4>', dap.step_out, { desc = ' Step out' })
  kmap('n', '<leader>dq', dap.close, { desc = 'DAP: Close session' })
  kmap('n', '<leader>dQ', dap.terminate, { desc = ' Terminate session' })
  kmap('n', '<leader>dr', dap.restart_frame, { desc = 'DAP: Restart' })
  kmap('n', '<F5>', dap.restart_frame, { desc = 'DAP: Restart' })
  kmap('n', '<leader>dc', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })
  kmap('n', '<leader>dR', dap.repl.toggle, { desc = 'DAP: Toggle REPL' })
  kmap('n', '<leader>dh', require('dap.ui.widgets').hover, { desc = 'DAP: Hover' })
  kmap('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Breakpoint' })
  kmap('n', '<leader>dB', function()
    local input = vim.fn.input 'Condition for breakpoint:'
    dap.set_breakpoint(input)
  end, { desc = 'DAP: Conditional Breakpoint' })
  kmap('n', '<leader>dD', dap.clear_breakpoints, { desc = 'DAP: Clear Breakpoints' })
end

-- NOTE:  codecompanion (<leader>i)
function M.codecompanion()
  kmap({ 'n', 'v' }, '<leader>ia', '<cmd>CodeCompanionActions<cr>', { desc = 'a[i] [a]ctions' })
  kmap('v', '<leader>is', '<cmd>CodeCompanionChat Add<cr>', { desc = 'a[i] [s]elect' })
  kmap('n', '<leader>ii', ':CodeCompanion ', { desc = 'a[i] [i]nline' })
end

-- NOTE: plugins (<leader>p)
function M.plugins()
  kmap('n', '<leader>pl', '<cmd>Lazy<CR>', { desc = 'open [l]azy.nvim' })
  kmap('n', '<leader>pm', '<cmd>Mason<CR>', { desc = 'open [M]ason' })
end

-- NOTE: toggle (;)
function M.toggle()
  -- toggle neo-tree
  kmap('n', ';e', ':Neotree toggle<CR>', { desc = 'NeoTree toggle' })
  kmap('n', ';f', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' })
  -- toggle terminal: this requires plugin 'snacks.terminal' to work
  kmap('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
  kmap( -- Toggle all terminals
    'n',
    ';t',
    function()
      local terms = Snacks.terminal.list()
      local any_visible = false
      for _, term in ipairs(terms) do
        if term.win and vim.api.nvim_win_is_valid(term.win) then
          any_visible = true
          break
        end
      end
      for _, term in ipairs(terms) do
        if any_visible then
          term:hide()
        else
          term:show()
        end
      end
    end,
    { desc = 'Toggle all terminals' }
  )
  kmap('n', ';T', function()
    Snacks.terminal.toggle(vim.o.shell, {
      win = {
        relative = 'editor',
        style = 'terminal', -- Use terminal style from config
      },
    })
  end, { desc = 'Create floating terminal' })
  -- toggle dapui
  kmap('n', ';d', require('dapui').toggle, { desc = 'Toggle DAP UI' })
  -- toggle codecompanion: this requires plugin 'codecompanion' to work
  kmap({ 'n', 'v' }, ';i', '<cmd>CodeCompanionChat Toggle<cr>', { desc = '[t]oggle a[i]' })
  -- toggle lazygit: using snacks.lazygit
  kmap('n', ';g', require('snacks').lazygit.open, { desc = '[t]oggle lazy[g]it' })
end

-- NOTE: native vim optimization
function M.native()
  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  kmap('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- NOTE: file operation (<leader>f)
  kmap('n', '<C-s>', ':w<CR>', { desc = '[f]ile [s]ave' })

  -- NOTE:  window operation (C to navigate, <leader>w to operate)

  --  See `:help wincmd` for a list of all window commands
  kmap('n', ';-', ':split<CR>', { desc = 'split horizontal' })
  kmap('n', ';\\', ':vsplit<CR>', { desc = 'split vertical' })
  kmap('n', '<C-h>', '<C-w>h', { desc = 'change to left window' })
  kmap('n', '<C-j>', '<C-w>j', { desc = 'change to lower window' })
  kmap('n', '<C-k>', '<C-w>k', { desc = 'change to upper window' })
  kmap('n', '<C-l>', '<C-w>l', { desc = 'change to right window' })
  kmap('n', '<leader>wd', '<C-w>q', { desc = 'delete window' })
  local snacks_win = nil
  kmap({ 'n', 't' }, '<C-z>', function()
    local current_win = vim.api.nvim_get_current_win()
    -- Close if already in snacks window
    if snacks_win and snacks_win:win_valid() and snacks_win.win == current_win then
      snacks_win:close()
      snacks_win = nil
      return
    end
    -- Close previous instance
    if snacks_win and snacks_win:win_valid() then
      snacks_win:close()
      snacks_win = nil
    end
    -- Get current buffer from active window
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    -- Create window with current buffer
    snacks_win = Snacks.win {
      buf = current_buf,
      width = 0.95,
      height = 0.95,
      border = 'rounded',
      wo = {
        spell = false,
        wrap = false,
        number = true,
        relativenumber = true,
        scrollbind = true,
        cursorbind = true,
      },
      on_win = function()
        vim.wo[current_win].scrollbind = true
        vim.wo[current_win].cursorbind = true
      end,
      on_close = function()
        vim.wo[current_win].scrollbind = false
        vim.wo[current_win].cursorbind = false
      end,
    }
  end, { desc = 'Toggle window fullscreen' })

  -- NOTE: code (<leader>c)
  kmap('n', '<leader>cc', 'gcc', { desc = '[c]ode toggle [c]omment', remap = true })
  kmap('v', '<leader>cc', 'gc', { desc = '[c]ode toggle [c]omment', remap = true })
end

return M
