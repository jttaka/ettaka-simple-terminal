local float_terms = {}

function ToggleFloatTerm()
  local cur_buf = vim.api.nvim_get_current_buf()

  -- If we're in a terminal, find its owner
  for owner, term in pairs(float_terms) do
    if term.buf == cur_buf then
      cur_buf = owner
      break
    end
  end

  float_terms[cur_buf] = float_terms[cur_buf] or {
    buf = nil,
    win = nil,
  }

  local term = float_terms[cur_buf]

  -- Toggle OFF
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_close(term.win, true)
    term.win = nil
    return
  end

  -- Create terminal buffer if needed
  if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
    term.buf = vim.api.nvim_create_buf(false, true)
  end

  -- Floating window
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  -- Root to file buffer directory
  local cwd = vim.fn.expand("#" .. cur_buf .. ":p:h")
  if cwd == "" then cwd = vim.loop.cwd() end

  -- Start terminal once
  if vim.bo[term.buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, { cwd = cwd })
  end

  vim.cmd("startinsert")
end

vim.keymap.set({ "n", "t" }, "<leader>t", function()
  vim.cmd("stopinsert")
  ToggleFloatTerm()
end, { desc = "Toggle buffer-local floating terminal" })

vim.api.nvim_create_autocmd({"BufDelete", "BufWipeout"}, {
  callback = function(args)
    local term = float_terms[args.buf]
    if not term then
      return
    end

    -- Close floating window if still open
    if term.win and vim.api.nvim_win_is_valid(term.win) then
      vim.api.nvim_win_close(term.win, true)
    end

    -- Kill terminal buffer (kills shell)
    if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
      vim.api.nvim_buf_delete(term.buf, { force = true })
    end

    -- Remove state
    float_terms[args.buf] = nil
  end,
})
