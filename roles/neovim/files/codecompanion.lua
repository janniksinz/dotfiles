return {
  'olimorris/codecompanion.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('codecompanion').setup {
      adapters = {
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            schema = { model = { default = 'claude-sonnet-4-20250514' } },
          })
        end,
      },
      strategies = {
        chat = { adapter = 'anthropic' },
        inline = { adapter = 'anthropic' },
      },
    }
  end,
  keys = {
    { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: Chat' },
    { '<leader>ce', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', desc = 'CodeCompanion: Add to chat' },
    { '<leader>ci', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion: Actions' },
  },
}
