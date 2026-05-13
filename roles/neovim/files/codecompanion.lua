local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'olimorris/codecompanion.nvim' }

require('codecompanion').setup {
  adapters = {
    anthropic = function()
      return require('codecompanion.adapters').extend('anthropic', {
        schema = {
          model = { default = 'claude-sonnet-4-20250514' },
        },
      })
    end,
  },
  strategies = {
    chat = { adapter = 'anthropic' },
    inline = { adapter = 'anthropic' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'CodeCompanion: Chat' })
vim.keymap.set('v', '<leader>ce', '<cmd>CodeCompanionChat Add<cr>', { desc = 'CodeCompanion: Add selection to chat' })
vim.keymap.set({ 'n', 'v' }, '<leader>ci', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion: Actions' })
