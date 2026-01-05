# simple-term

Simple terminal script by ettaka turned into a plugin by jttaka.
Original code from ettaka/toolsrc/nvim-lua/after/plugin/simple_term.lua

Usage:
:ToggleFloatTerm toggles floating terminal

Add the recomended mapping (\t toggles floating terminal):
```lua
vim.keymap.set({ "n", "t" }, "<leader>t", function()
  vim.cmd("stopinsert")
  ToggleFloatTerm()
end, { desc = "Toggle buffer-local floating terminal" })
```
