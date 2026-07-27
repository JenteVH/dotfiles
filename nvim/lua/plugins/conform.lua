return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- black comes from the project venv (direnv puts .venv/bin on PATH)
        python = { "black" },
        -- clang-format reads .clang-format from the project root
        cpp = { "clang-format" },
        c = { "clang-format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      -- projects without black in their venv: stay quiet instead of nagging on save
      notify_no_formatters = false,
    },
  },
}
