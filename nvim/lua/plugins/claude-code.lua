return {
  {
    "coder/claudecode.nvim",
    lazy = false, -- Load immediately so commands are available
    dependencies = {
      "folke/snacks.nvim",
    },
    config = true, -- Use default configuration
    keys = {
      { "<leader>a", group = "Claude AI" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer" },
      { "<leader>at", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add from tree" },
      {
        "<leader>ap",
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):lower():match("claude") then
              local prev_win = vim.api.nvim_get_current_win()
              vim.api.nvim_set_current_win(win)
              if vim.api.nvim_win_get_width(win) < vim.o.columns * 0.9 then
                vim.cmd("wincmd K")
              else
                vim.cmd("wincmd L")
              end
              vim.api.nvim_set_current_win(prev_win)
              return
            end
          end
        end,
        desc = "Toggle Claude split direction",
      },
    },
  },
}
