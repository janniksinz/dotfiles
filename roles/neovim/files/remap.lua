vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open file explorer' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join lines, keep cursor' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down, center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up, center' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search, center' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search, center' })

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete to void register' })

vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = 'Tmux sessionizer' })

vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz', { desc = 'Quickfix next' })
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz', { desc = 'Quickfix prev' })
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz', { desc = 'Location list next' })
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz', { desc = 'Location list prev' })

vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'Make file executable' })
