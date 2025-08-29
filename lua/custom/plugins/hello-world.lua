local function get_git_modified_files()
  local handle = io.popen('git status --porcelain 2>/dev/null')
  if not handle then
    return {}, {'No git repository found'}
  end
  
  local result = handle:read('*a')
  handle:close()
  
  if result == '' then
    return {}, {'No modified files'}
  end
  
  local files = {}
  local file_paths = {}
  for line in result:gmatch('[^\r\n]+') do
    local status = line:sub(1, 2)
    local file = line:sub(4)
    table.insert(files, status .. ' ' .. file)
    table.insert(file_paths, file)
  end
  
  return file_paths, files
end

local function create_floating_window()
  local file_paths, modified_files = get_git_modified_files()
  local width = math.max(40, math.min(80, vim.o.columns - 10))
  local height = math.max(10, math.min(#modified_files + 2, vim.o.lines - 6))

  local buf = vim.api.nvim_create_buf(false, true)

  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Git Modified Files ',
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, modified_files)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)

  -- Set cursor to first line if there are files
  if #file_paths > 0 then
    vim.api.nvim_win_set_cursor(win, {1, 0})
  end

  -- Navigation functions
  local function move_cursor(direction)
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    local new_line
    
    if direction == 'up' then
      new_line = math.max(1, current_line - 1)
    else -- down
      new_line = math.min(#modified_files, current_line + 1)
    end
    
    vim.api.nvim_win_set_cursor(win, {new_line, 0})
  end

  -- Open selected file
  local function open_selected_file()
    if #file_paths == 0 then return end
    
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    local selected_file = file_paths[current_line]
    
    if selected_file then
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. vim.fn.fnameescape(selected_file))
    end
  end

  -- Key mappings
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<C-p>', function()
    move_cursor('up')
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<C-n>', function()
    move_cursor('down')
  end, { buffer = buf, silent = true })

  vim.keymap.set('n', '<CR>', open_selected_file, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Enter>', open_selected_file, { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command('HelloWorld', create_floating_window, {
  desc = 'Open a floating window with git modified files',
})

vim.keymap.set('n', '<leader>hw', create_floating_window, {
  desc = 'Open git modified files floating window',
})

return {}

