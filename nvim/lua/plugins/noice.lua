return {
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
      views = {
        cmdline_popup = {
          position = {
            row = "10%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
      },
    },
  },
}
