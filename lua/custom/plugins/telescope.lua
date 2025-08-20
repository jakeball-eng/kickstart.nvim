return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      vim.keymap.set('n', '<space>fd', require('telescope.builtin').find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<space>eh', function()
        require('telescope.builtin').find_files {
          cwd = '~/.config/hypr',
        }
      end, { desc = 'Edit Hyprland config' })
      vim.keymap.set('n', '<space>en', function()
        require('telescope.builtin').find_files {
          cwd = vim.fn.stdpath 'config',
        }
      end, { desc = 'Edit Neovim config' })
      vim.keymap.set('n', '<space>gr', require('telescope.builtin').lsp_references, { desc = 'LSP References' })

      vim.keymap.set('n', '<space>fg', require('telescope.builtin').live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<space>fw', require('telescope.builtin').grep_string, { desc = 'Find word under cursor' })
      vim.keymap.set('n', '<space>fs', require('telescope.builtin').lsp_document_symbols, { desc = 'Document symbols' })
      vim.keymap.set('n', '<space>fS', require('telescope.builtin').lsp_workspace_symbols, { desc = 'Workspace symbols' })
    end,
  },
}
