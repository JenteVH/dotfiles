return {
  -- DAP UI (separate to ensure proper setup)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Debug: Eval", mode = { "n", "v" } },
    },
    config = function()
      local dapui = require("dapui")
      local dap = require("dap")

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-telescope/telescope-dap.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
    },
    config = function()
      local dap = require("dap")

      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.adapters.debugpy_remote = function(cb, config)
        cb({
          type = "server",
          host = config.connect.host,
          port = config.connect.port,
        })
      end

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
          end,
        },
        {
          type = "debugpy_remote",
          request = "attach",
          name = "Attach to Docker",
          connect = function()
            return {
              host = "127.0.0.1",
              port = tonumber(vim.fn.input("Port: ")) or 5678,
            }
          end,
          pathMappings = {
            {
              localRoot = function()
                return vim.fn.getcwd()
              end,
              remoteRoot = "/app",
            },
          },
        },
      }

      require("nvim-dap-virtual-text").setup()
    end,
  },

  -- Python specific debugging
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python",
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")

      dap_python.setup(vim.fn.exepath("python3") or vim.fn.exepath("python") or "python")
      dap_python.test_runner = "pytest"

      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "Attach to Docker",
        connect = function()
          return {
            host = "127.0.0.1",
            port = tonumber(vim.fn.input("Port: ")) or 5678,
          }
        end,
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = "/app",
          },
        },
      })

      vim.keymap.set("n", "<leader>dn", dap_python.test_method, { desc = "Debug: Test method" })
      vim.keymap.set("n", "<leader>df", dap_python.test_class, { desc = "Debug: Test class" })
      vim.keymap.set("v", "<leader>ds", dap_python.debug_selection, { desc = "Debug: Selection" })
    end,
  },

  -- Go specific debugging
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "go",
    config = function()
      require("dap-go").setup({
        -- Delve configuration
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        -- Delve CLI command
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
      })

      -- Keymaps for Go debugging
      vim.keymap.set("n", "<leader>dt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug: Go Test" })
      vim.keymap.set("n", "<leader>dT", function()
        require("dap-go").debug_last_test()
      end, { desc = "Debug: Go Last Test" })
    end,
  },

  -- PHP specific debugging (xdebug)
  {
    "mfussenegger/nvim-dap",
    ft = "php",
    config = function()
      local dap = require("dap")

      -- PHP adapter using vscode-php-debug
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/php-debug/out/phpDebug.js" },
      }

      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug",
          port = 9003,
          pathMappings = {
            -- Adjust for Docker: container path -> local path
            ["/var/www/html"] = "${workspaceFolder}",
          },
        },
        {
          type = "php",
          request = "launch",
          name = "Launch current script",
          program = "${file}",
          cwd = "${fileDirname}",
          port = 0,
          runtimeArgs = { "-dxdebug.start_with_request=yes" },
          env = {
            XDEBUG_MODE = "debug,develop",
            XDEBUG_CONFIG = "client_port=${port}",
          },
        },
      }
    end,
  },
}
