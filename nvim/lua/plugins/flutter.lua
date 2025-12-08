return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      -- Get capabilities from nvim-cmp (same as other LSPs)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP attach function (reuse the same pattern from lsp-native.lua)
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Standard LSP keymaps
        buf_set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        buf_set_keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        buf_set_keymap("n", "K", vim.lsp.buf.hover, "Hover documentation")
        buf_set_keymap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        buf_set_keymap("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        buf_set_keymap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        buf_set_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        buf_set_keymap("n", "gr", vim.lsp.buf.references, "Find references")
        buf_set_keymap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format document")

        -- Flutter-specific keybindings using <leader>F prefix
        buf_set_keymap("n", "<leader>Fr", "<cmd>FlutterRun<cr>", "Flutter Run")
        buf_set_keymap("n", "<leader>Fd", "<cmd>FlutterDevices<cr>", "Flutter Devices")
        buf_set_keymap("n", "<leader>Fe", "<cmd>FlutterEmulators<cr>", "Flutter Emulators")
        buf_set_keymap("n", "<leader>FR", "<cmd>FlutterReload<cr>", "Flutter Hot Reload")
        buf_set_keymap("n", "<leader>Fs", "<cmd>FlutterRestart<cr>", "Flutter Hot Restart")
        buf_set_keymap("n", "<leader>Fq", "<cmd>FlutterQuit<cr>", "Flutter Quit")
        buf_set_keymap("n", "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", "Flutter Outline")
        buf_set_keymap("n", "<leader>Fl", "<cmd>FlutterLspRestart<cr>", "Flutter LSP Restart")
      end

      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "nvim-notify",
        },
        decorations = {
          statusline = {
            app_version = false,
            device = true,
            project_config = false,
          },
        },
        debugger = {
          enabled = false, -- Can be enabled if nvim-dap is configured
          run_via_dap = false,
        },
        flutter_path = nil, -- Uses flutter from PATH
        flutter_lookup_cmd = nil, -- Uses default lookup
        fvm = false, -- Set to true if using FVM
        widget_guides = {
          enabled = true, -- Shows guides for nested widgets
        },
        closing_tags = {
          highlight = "Comment", -- Highlight closing widget tags
          prefix = "// ", -- Character to use for closing tag e.g. > Widget
          enabled = true, -- Set to false to disable
        },
        dev_log = {
          enabled = true,
          notify_errors = false, -- Don't spam with errors
          open_cmd = "tabedit", -- Command to open the log buffer
        },
        dev_tools = {
          autostart = false, -- Don't auto-open DevTools
          auto_open_browser = false, -- Don't auto-open browser
        },
        outline = {
          open_cmd = "30vnew", -- Command to open the outline window
          auto_open = false, -- Don't auto-open outline
        },
        lsp = {
          color = {
            enabled = true, -- Show colors in the editor
            background = false, -- Don't highlight background
            background_color = nil,
            foreground = false,
            virtual_text = true, -- Show color as virtual text
            virtual_text_str = "■", -- Character for virtual text
          },
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
      })

      -- Telescope integration (optional)
      pcall(function()
        require("telescope").load_extension("flutter")
        vim.keymap.set("n", "<leader>Ft", "<cmd>Telescope flutter commands<cr>",
          { desc = "Flutter Telescope Commands" })
      end)
    end,
  },
}
