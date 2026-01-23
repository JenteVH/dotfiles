return {
  -- Colorscheme + Transparency
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    dependencies = { "xiyaowong/transparent.nvim" },
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          keywords = { "italic" },
          booleans = { "italic" },
        },
        integrations = {
          treesitter = true,
          native_lsp = { enabled = true },
          telescope = { enabled = true },
          which_key = true,
          indent_blankline = { enabled = true },
          nvimtree = true,
          gitsigns = true,
          bufferline = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")

      require("transparent").setup({
        groups = {
          'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
          'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
          'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
          'SignColumn', 'StatusLine', 'StatusLineNC', 'EndOfBuffer',
        },
        extra_groups = {
          "NormalFloat",
          "FloatBorder",
          "NvimTreeNormal",
          "NvimTreeNormalNC",
          "TelescopeNormal",
          "TelescopeBorder",
          "WhichKeyFloat",
          "BufferLineFill",
          "BufferLineBackground",
        },
      })
      vim.cmd("TransparentEnable")

      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#24283b" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#89b4fa", bold = true })
    end,
  },

  -- Cyberdream colorscheme (use :colorscheme cyberdream to activate)
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = false,
        italic_comments = true,
        borderless_telescope = true,
        overrides = function(colors)
          return {
            -- Italic keywords for cursive Victor Mono styling
            ["@keyword"] = { italic = true },
            ["@keyword.function"] = { italic = true },
            ["@keyword.return"] = { italic = true },
            ["@keyword.operator"] = { italic = true },
            ["@keyword.conditional"] = { italic = true },
            ["@keyword.repeat"] = { italic = true },
            ["@keyword.import"] = { italic = true },
            ["@keyword.exception"] = { italic = true },
            ["@boolean"] = { italic = true },
            ["@constant.builtin"] = { italic = true },
          }
        end,
      })
    end,
  },

  -- OneDark Pro colorscheme
  {
    "olimorris/onedarkpro.nvim",
    lazy = true,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 1,  -- 0 = just filename, 1 = relative path, 2 = absolute path, 3 = absolute with ~
            }
          },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 100  -- Very fast response for leader key
    end,
    config = function()
      require("which-key").setup()
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
      })
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']h', function()
            if vim.wo.diff then return ']h' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = "Next hunk"})

          map('n', '[h', function()
            if vim.wo.diff then return '[h' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = "Previous hunk"})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
          map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Stage hunk" })
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Reset hunk" })
          map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
          map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview hunk" })
          map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "Blame line" })
          map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = "Diff this ~" })
          map('n', '<leader>gd', gs.toggle_deleted, { desc = "Toggle deleted" })

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select hunk" })
        end,
      })
    end,
  },
}
