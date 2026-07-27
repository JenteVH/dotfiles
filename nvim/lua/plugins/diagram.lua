local function has_ui()
  return #vim.api.nvim_list_uis() > 0
end

return {
  {
    "3rd/image.nvim",
    lazy = true,
    cond = has_ui,
    opts = {
      backend = "kitty",
      processor = "magick_cli",
    },
  },
  {
    "3rd/diagram.nvim",
    cond = has_ui,
    ft = { "markdown", "mermaid" },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.filetype.add({
        extension = {
          mmd = "mermaid",
          mermaid = "mermaid",
        },
      })
    end,
    keys = {
      {
        "<leader>md",
        function()
          require("diagram").show_diagram_hover()
        end,
        mode = "n",
        ft = { "markdown", "mermaid" },
        desc = "Show diagram at cursor",
      },
    },
    opts = function()
      local renderers = require("diagram/renderers")
      local mermaid_file_integration = {
        id = "mermaid_file",
        filetypes = { "mermaid" },
        renderers = { renderers.mermaid },
        query_buffer_diagrams = function(bufnr)
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local source = table.concat(lines, "\n")
          if vim.trim(source) == "" then
            return {}
          end

          return {
            {
              bufnr = bufnr,
              renderer_id = "mermaid",
              source = source,
              range = {
                start_row = 0,
                start_col = 0,
                end_row = math.max(#lines - 1, 0),
                end_col = 0,
              },
            },
          }
        end,
      }

      return {
        events = {
          render_buffer = {},
          clear_buffer = { "BufLeave" },
        },
        renderer_options = {
          mermaid = {
            scale = 2,
            width = 1600,
          },
        },
        integrations = {
          require("diagram.integrations.markdown"),
          mermaid_file_integration,
        },
      }
    end,
    config = function(_, opts)
      require("diagram").setup(opts)
    end,
  },
}
