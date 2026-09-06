return {
  {
    "ishiooon/codex.nvim",
    lazy = true,
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "Codex",
      "CodexFocus",
      "CodexMaximizeToggle",
      "CodexSend",
      "CodexAdd",
      "CodexStart",
      "CodexStop",
      "CodexStatus",
    },
    opts = function()
      return {
        auto_start = #vim.api.nvim_list_uis() > 0,
        terminal_cmd = "codex",
        -- Keep Codex separate from the existing buffer and Claude mappings.
        keymaps = { enabled = false },
        terminal = { provider = "snacks", split_side = "right" },
        -- Accurate status requires a separate Codex CLI notify hook.
        status_indicator = { enabled = false },
      }
    end,
    keys = {
      { "<leader>kt", "<cmd>Codex<cr>", desc = "Toggle Codex" },
      { "<leader>kf", "<cmd>CodexFocus<cr>", desc = "Focus or hide Codex" },
      { "<leader>km", "<cmd>CodexMaximizeToggle<cr>", desc = "Toggle Codex maximized view" },
      { "<leader>ks", "<cmd>CodexSend<cr>", mode = "x", desc = "Send selection to Codex" },
      { "<leader>kb", "<cmd>CodexAdd %<cr>", desc = "Add buffer to Codex" },
    },
  },
}
