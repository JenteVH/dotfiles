local palette = {
  rosewater = "#f5d49c",
  flamingo = "#ff9f8f",
  pink = "#ff7eb6",
  mauve = "#a88bff",
  red = "#ff6b7a",
  maroon = "#ff8d6b",
  peach = "#ffb454",
  yellow = "#e6c15a",
  green = "#69d39b",
  teal = "#00c7a3",
  sky = "#74d6f6",
  sapphire = "#54b6ff",
  blue = "#6a9cff",
  lavender = "#9fb8ff",
  text = "#d6deeb",
  subtext1 = "#a8b3c5",
  subtext0 = "#8e9aae",
  overlay2 = "#78849a",
  overlay1 = "#5d6779",
  overlay0 = "#465061",
  surface2 = "#323a4d",
  surface1 = "#262f40",
  surface0 = "#1c2433",
  base = "#12161f",
  mantle = "#0f131c",
  crust = "#0b0f16",
}

local function mode_theme(accent)
  return {
    a = { bg = accent, fg = palette.crust, gui = "bold" },
    b = { bg = palette.surface0, fg = palette.text },
    c = { bg = palette.mantle, fg = palette.subtext1 },
  }
end

local lualine_theme = {
  normal = mode_theme(palette.teal),
  insert = mode_theme(palette.blue),
  visual = mode_theme(palette.mauve),
  replace = mode_theme(palette.red),
  command = mode_theme(palette.peach),
  inactive = {
    a = { bg = palette.crust, fg = palette.overlay0, gui = "bold" },
    b = { bg = palette.crust, fg = palette.overlay0 },
    c = { bg = palette.crust, fg = palette.overlay1 },
  },
}

return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        color_overrides = {
          mocha = palette,
        },
        custom_highlights = function(colors)
          return {
            Normal = { fg = colors.text, bg = colors.base },
            NormalNC = { fg = colors.text, bg = colors.base },
            SignColumn = { bg = colors.base },
            CursorLine = { bg = colors.surface0 },
            CursorLineNr = { fg = colors.teal, bold = true },
            LineNr = { fg = colors.surface2 },
            Visual = { bg = colors.surface1 },
            Search = { fg = colors.crust, bg = colors.yellow },
            IncSearch = { fg = colors.crust, bg = colors.mauve },
            StatusLine = { fg = colors.subtext1, bg = colors.mantle },
            StatusLineNC = { fg = colors.overlay1, bg = colors.crust },
            WinSeparator = { fg = colors.surface1 },
            NormalFloat = { bg = colors.mantle },
            FloatBorder = { fg = colors.surface2, bg = colors.mantle },
            FloatTitle = { fg = colors.teal, bg = colors.mantle, bold = true },
            Pmenu = { fg = colors.text, bg = colors.mantle },
            PmenuSel = { fg = colors.text, bg = colors.surface1, bold = true },
            PmenuSbar = { bg = colors.surface0 },
            PmenuThumb = { bg = colors.surface2 },
            CmpItemAbbrMatch = { fg = colors.teal, bold = true },
            CmpItemAbbrDeprecated = { fg = colors.overlay1, strikethrough = true },
            CmpItemKind = { fg = colors.lavender },
            CmpItemMenu = { fg = colors.overlay1 },
            TelescopeNormal = { bg = colors.mantle },
            TelescopeBorder = { fg = colors.surface2, bg = colors.mantle },
            TelescopePromptNormal = { bg = colors.surface0 },
            TelescopePromptBorder = { fg = colors.surface2, bg = colors.surface0 },
            TelescopePromptPrefix = { fg = colors.teal, bg = colors.surface0 },
            TelescopeSelection = { bg = colors.surface1, bold = true },
            TelescopeMatching = { fg = colors.teal, bold = true },
            TelescopeResultsTitle = { fg = colors.crust, bg = colors.mauve, bold = true },
            TelescopePromptTitle = { fg = colors.crust, bg = colors.teal, bold = true },
            TelescopePreviewTitle = { fg = colors.crust, bg = colors.blue, bold = true },
            WhichKeyFloat = { bg = colors.mantle },
            NvimTreeNormal = { bg = colors.crust },
            NvimTreeNormalNC = { bg = colors.crust },
            NvimTreeWinSeparator = { fg = colors.surface1, bg = colors.crust },
            NvimTreeCursorLine = { bg = colors.surface0 },
            NvimTreeRootFolder = { fg = colors.lavender, bold = true },
            NvimTreeOpenedFolderName = { fg = colors.teal, bold = true },
            BufferLineFill = { bg = colors.crust },
            BufferLineBackground = { fg = colors.overlay0, bg = colors.mantle },
            BufferLineBufferSelected = { fg = colors.text, bg = colors.base, bold = true },
            BufferLineIndicatorSelected = { fg = colors.teal, bg = colors.base },
            BufferLineSeparator = { fg = colors.crust, bg = colors.mantle },
            BufferLineSeparatorSelected = { fg = colors.crust, bg = colors.base },
            BufferLineModifiedSelected = { fg = colors.peach, bg = colors.base },
            BufferLineCloseButtonSelected = { fg = colors.red, bg = colors.base },
            DiffAdd = { bg = "#142b24" },
            DiffChange = { bg = "#1c2740" },
            DiffDelete = { bg = "#31171d" },
            DiffText = { bg = "#243759" },
            GitSignsAdd = { fg = colors.green },
            GitSignsChange = { fg = colors.yellow },
            GitSignsDelete = { fg = colors.red },
            DiagnosticVirtualTextError = { fg = colors.red, bg = colors.mantle },
            DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = colors.mantle },
            DiagnosticVirtualTextInfo = { fg = colors.blue, bg = colors.mantle },
            DiagnosticVirtualTextHint = { fg = colors.teal, bg = colors.mantle },
            IlluminatedWordText = { bg = colors.surface1 },
            IlluminatedWordRead = { bg = colors.surface1 },
            IlluminatedWordWrite = { bg = colors.surface1 },
          }
        end,
        integrations = {
          treesitter = true,
          native_lsp = { enabled = true },
          cmp = true,
          telescope = { enabled = true },
          which_key = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          nvimtree = true,
          lsp_trouble = true,
          gitsigns = true,
          bufferline = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
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
          theme = lualine_theme,
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

  -- Highlight other uses of the word under the cursor (IDE-style)
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 100,
        filetypes_denylist = {
          "NvimTree",
          "TelescopePrompt",
          "lazy",
          "mason",
          "help",
          "dashboard",
          "neo-tree",
          "lazygit",
        },
        under_cursor = true,
        min_count_to_highlight = 2,
      })

      vim.keymap.set("n", "]]", function() require("illuminate").goto_next_reference(false) end, { desc = "Next reference" })
      vim.keymap.set("n", "[[", function() require("illuminate").goto_prev_reference(false) end, { desc = "Prev reference" })
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
