return {
  {
    "coder/claudecode.nvim",
    lazy = false, -- Load immediately so commands are available
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = function()
      return {
        auto_start = #vim.api.nvim_list_uis() > 0,
        diff_opts = {
          open_in_new_tab = true,
          hide_terminal_in_new_tab = true,
        },
      }
    end,
    config = function(_, opts)
      require("claudecode").setup(opts)

      local diff = require("claudecode.diff")

      local function get_current_diff_tab_name()
        local tab_name = vim.b.claudecode_diff_tab_name
        if tab_name then
          return tab_name
        end

        local active_diffs = diff._get_active_diffs()
        for active_tab_name, diff_data in pairs(active_diffs) do
          if diff_data.status == "pending" then
            return active_tab_name
          end
        end
      end

      local function restore_after_diff(diff_data)
        if not diff_data then
          return
        end

        if diff_data.original_tab_number and vim.api.nvim_tabpage_is_valid(diff_data.original_tab_number) then
          pcall(vim.api.nvim_set_current_tabpage, diff_data.original_tab_number)
        end

        if diff_data.old_file_path then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local bufnr = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_get_name(bufnr) == diff_data.old_file_path then
              vim.api.nvim_set_current_win(win)
              if diff_data.original_cursor_pos then
                pcall(vim.api.nvim_win_set_cursor, win, diff_data.original_cursor_pos)
                vim.cmd("normal! zz")
              end
              return
            end
          end
        end
      end

      local function close_diff_tab(tab_name)
        if not tab_name then
          return
        end

        local diff_data = diff._get_active_diffs()[tab_name]
        diff.close_diff_by_tab_name(tab_name)
        restore_after_diff(diff_data)
      end

      local function accept_diff(tab_name)
        tab_name = tab_name or get_current_diff_tab_name()
        if not tab_name then
          vim.notify("No active Claude diff found", vim.log.levels.WARN)
          return
        end

        local diff_data = diff._get_active_diffs()[tab_name]
        if not diff_data or not diff_data.new_buffer then
          vim.notify("No active Claude diff found", vim.log.levels.WARN)
          return
        end

        diff._resolve_diff_as_saved(tab_name, diff_data.new_buffer)
        close_diff_tab(tab_name)
      end

      local function deny_diff(tab_name)
        tab_name = tab_name or get_current_diff_tab_name()
        if not tab_name then
          vim.notify("No active Claude diff found", vim.log.levels.WARN)
          return
        end

        close_diff_tab(tab_name)
      end

      local register_diff_state = diff._register_diff_state
      diff._register_diff_state = function(tab_name, diff_data)
        register_diff_state(tab_name, diff_data)

        for _, bufnr in ipairs({ diff_data.original_buffer, diff_data.new_buffer }) do
          if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            vim.b[bufnr].claudecode_diff_tab_name = tab_name
            vim.keymap.set("n", "q", function()
              deny_diff(tab_name)
            end, { buffer = bufnr, desc = "Close Claude diff" })
            vim.keymap.set("n", "<Esc>", function()
              deny_diff(tab_name)
            end, { buffer = bufnr, desc = "Close Claude diff" })
            vim.keymap.set("n", "<leader>aa", function()
              accept_diff(tab_name)
            end, { buffer = bufnr, desc = "Accept Claude diff" })
            vim.keymap.set("n", "<leader>ad", function()
              deny_diff(tab_name)
            end, { buffer = bufnr, desc = "Deny Claude diff" })
          end
        end
      end

      vim.api.nvim_create_user_command("ClaudeCodeDiffAccept", function()
        accept_diff()
      end, { desc = "Accept the current diff changes" })

      vim.api.nvim_create_user_command("ClaudeCodeDiffDeny", function()
        deny_diff()
      end, { desc = "Deny/reject the current diff changes" })
    end,
    keys = {
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
