return {
  -- Motion plugin
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function()
      vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap-forward)')
      vim.keymap.set({'n', 'x', 'o'}, 'S', '<Plug>(leap-backward)')
      vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
      require('leap').opts.safe_labels = {}
    end,
  },

  -- Diagnostics list
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },

  -- Tree view file explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35,
          side = "left",
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { ".git" },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
          change_dir = {
            restrict_above_cwd = true,
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>;", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree explorer" })
      vim.keymap.set("n", "<leader>:", "<cmd>NvimTreeFindFile<CR>", { desc = "Find file in tree" })
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          always_show_bufferline = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          color_icons = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
      vim.keymap.set("n", "<leader>bL", ":BufferLineMoveNext<CR>", { desc = "Move buffer right" })
      vim.keymap.set("n", "<leader>bH", ":BufferLineMovePrev<CR>", { desc = "Move buffer left" })
      vim.keymap.set("n", "<leader>bp", ":BufferLineTogglePin<CR>", { desc = "Pin buffer" })
      vim.keymap.set("n", "<leader>bP", ":BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
      vim.keymap.set("n", "<leader>bo", ":BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
      vim.keymap.set("n", "<leader>br", ":BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
      vim.keymap.set("n", "<leader>bl", ":BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
    end,
  },

  -- Toggleterm for terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "vertical" then
            return 80
          end

          return 20
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
        },
      })

      local function focus_editor_window()
        local current_win = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_win_get_buf(current_win)
        if vim.bo[current_buf].buftype ~= "terminal" then
          return
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local win_config = vim.api.nvim_win_get_config(win)
          if vim.bo[buf].buftype ~= "terminal" and not (win_config.relative and win_config.relative ~= "") then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end

      local function toggle_terminal(direction, id)
        return function()
          if direction ~= "float" then
            focus_editor_window()
          end

          vim.cmd(id .. "ToggleTerm direction=" .. direction)
        end
      end

      local terminal_kinds = {
        { key = "f", direction = "float", name = "floating" },
        { key = "h", direction = "horizontal", name = "horizontal" },
        { key = "v", direction = "vertical", name = "vertical" },
      }

      for _, kind in ipairs(terminal_kinds) do
        vim.keymap.set("n", "<leader>t" .. kind.key, toggle_terminal(kind.direction, 1), {
          desc = "Toggle " .. kind.name .. " terminal",
        })
        for i = 1, 9 do
          vim.keymap.set("n", "<leader>t" .. kind.key .. i, toggle_terminal(kind.direction, i), {
            desc = "Toggle " .. kind.name .. " terminal " .. i,
          })
        end
      end
      vim.keymap.set("n", "<leader>ts", "<cmd>TermSelect<CR>", { desc = "Select terminal" })
      vim.keymap.set("n", "<leader>ta", "<cmd>ToggleTermToggleAll<CR>", { desc = "Toggle all terminals" })
    end,
  },

}
