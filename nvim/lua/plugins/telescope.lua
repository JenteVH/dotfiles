return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = {
          "kkharji/sqlite.lua",
        },
      },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          path_display = { "smart" },
          sorting_strategy = "ascending",
          scroll_strategy = "limit",
          file_ignore_patterns = {
            "node_modules",
            "__pycache__",
            "%.pyc",
            "%.pyo",
            "%.pyd",
            "%.so",
            "%.egg",
            "%.egg-info",
            ".git",
            ".venv",
            "venv",
            "yarn.lock",
            "package-lock.json",
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<C-n>"] = "cycle_history_next",
              ["<C-p>"] = "cycle_history_prev",
              ["<C-q>"] = actions.smart_send_to_qflist,
              ["<C-s>"] = "select_horizontal",
            },
            n = {
              ["<C-q>"] = actions.smart_send_to_qflist,
              ["q"] = "close",
            },
          },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          cache_picker = {
            num_pickers = 10,
            limit_entries = 1000,
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            follow = true,
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
          buffers = {
            sort_mru = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<C-d>"] = "delete_buffer",
              },
              n = {
                ["dd"] = "delete_buffer",
              },
            },
          },
          oldfiles = {
            cwd_only = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          frecency = {
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = {
              "*.git/*",
              "*/tmp/*",
              "*/node_modules/*",
              "*/__pycache__/*",
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")

      local function lsp_supports(method)
        if not method then
          return true
        end

        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          if client.supports_method and client:supports_method(method) then
            return true
          end
        end
        return false
      end

      local function map_lsp(key, picker, opts)
        opts = opts or {}
        local method = opts.method
        local desc = opts.desc
        local fallback = opts.fallback

        vim.keymap.set("n", key, function()
          if lsp_supports(method) then
            picker()
            return
          end

          if fallback then
            fallback()
            return
          end

          vim.notify(
            string.format("LSP server does not support %s", method or "the requested operation"),
            vim.log.levels.WARN
          )
        end, { desc = desc })
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files({ cwd = vim.fn.getcwd() })
      end, { desc = "Find files in project" })
      
      
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep in project" })
      
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find commands" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find old files" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })
      
      -- Git pickers
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
      
      -- LSP pickers
      map_lsp("<leader>lr", function()
        builtin.lsp_references()
      end, { desc = "LSP references", method = "textDocument/references" })

      map_lsp("<leader>ls", function()
        builtin.lsp_document_symbols()
      end, { desc = "LSP document symbols", method = "textDocument/documentSymbol" })

      map_lsp("<leader>lw", function()
        builtin.lsp_workspace_symbols()
      end, { desc = "LSP workspace symbols", method = "workspace/symbol" })

      map_lsp("<leader>li", function()
        builtin.lsp_implementations()
      end, {
        desc = "LSP implementations",
        method = "textDocument/implementation",
        fallback = function()
          builtin.lsp_definitions()
        end,
      })

      map_lsp("<leader>ld", function()
        builtin.lsp_definitions()
      end, { desc = "LSP definitions", method = "textDocument/definition" })

      map_lsp("<leader>lt", function()
        builtin.lsp_type_definitions()
      end, {
        desc = "LSP type definitions",
        method = "textDocument/typeDefinition",
        fallback = function()
          builtin.lsp_definitions()
        end,
      })
    end,
  },
}
