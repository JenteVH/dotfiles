return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      "windwp/nvim-ts-autotag",
    },
    config = function()
      -- Use a writable location for parsers (needed for Docker)
      local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter-parsers"
      vim.opt.runtimepath:prepend(parser_install_dir)

      local incremental_selection = require("nvim-treesitter.incremental_selection")
      local parsers = require("nvim-treesitter.parsers")

      local function with_parser(fn)
        return function()
          if not parsers.has_parser() then
            return
          end

          fn()
        end
      end

      require("nvim-treesitter.configs").setup({
        parser_install_dir = parser_install_dir,
        ensure_installed = {
          "python",
          "lua",
          "rust",
          "vim",
          "vimdoc",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "dockerfile",
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",
          "regex",
          "sql",
          "dart",
          "php",
          "php_only",
          "blade",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          disable = { "dart", "rust" },
        },
        autotag = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
            node_incremental = false,
            scope_incremental = false,
            node_decremental = false,
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>A"] = "@parameter.inner",
            },
          },
        },
      })

      local selection_keymaps = {
        n = {
          ["<M-Space>"] = { incremental_selection.init_selection, "Start incremental selection" },
          ["<C-Space>"] = { incremental_selection.init_selection, "Start incremental selection" },
          ["<C-@>"] = { incremental_selection.init_selection, "Start incremental selection" },
        },
        x = {
          ["<M-Space>"] = { incremental_selection.node_incremental, "Increment selection to named node" },
          ["<C-Space>"] = { incremental_selection.node_incremental, "Increment selection to named node" },
          ["<C-@>"] = { incremental_selection.node_incremental, "Increment selection to named node" },
          ["<C-s>"] = { incremental_selection.scope_incremental, "Increment selection to surrounding scope" },
          ["<M-BS>"] = { incremental_selection.node_decremental, "Shrink selection to previous named node" },
          ["<M-Del>"] = { incremental_selection.node_decremental, "Shrink selection to previous named node" },
          ["<C-BS>"] = { incremental_selection.node_decremental, "Shrink selection to previous named node" },
          ["<BS>"] = { incremental_selection.node_decremental, "Shrink selection to previous named node" },
        },
      }

      for mode, mappings in pairs(selection_keymaps) do
        for lhs, mapping in pairs(mappings) do
          vim.keymap.set(mode, lhs, with_parser(mapping[1]), {
            silent = true,
            desc = mapping[2],
          })
        end
      end
    end,
  },
}
