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

return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = false,
        color_overrides = {
          mocha = palette,
        },
        custom_highlights = function(colors)
          return {
            Normal = { fg = colors.text, bg = colors.base },
            NormalNC = { fg = colors.text, bg = colors.base },
            Cursor = { fg = colors.crust, bg = colors.rosewater, bold = true },
            TermCursor = { fg = colors.crust, bg = colors.rosewater, bold = true },
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
            GitSignsAdd = { fg = colors.green },
            GitSignsChange = { fg = colors.yellow },
            GitSignsDelete = { fg = colors.red },
            GitSignsCurrentLineBlame = { fg = colors.subtext1, bg = colors.surface0, italic = true },
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
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },

  -- Rosé Pine colorscheme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "dawn",
        palette = {
          dawn = {
            text = "#3f3b57",
            muted = "#746f82",
            subtle = "#6d6984",
            love = "#a2596e",
            gold = "#ad711d",
            rose = "#ac5f5c",
            pine = "#245e76",
            foam = "#4d858f",
            iris = "#826e98",
            leaf = "#62817b",
          },
        },
        highlight_groups = {
          IlluminatedWordText = { bg = "#d6d2d3" },
          IlluminatedWordRead = { bg = "#d6d2d3" },
          IlluminatedWordWrite = { bg = "#d6d2d3" },
        },
      })
      vim.cmd.colorscheme("rose-pine-dawn")
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
          theme = "auto",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { 'filename', path = 1 }
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
      vim.o.timeoutlen = 200  -- Still fast, but more forgiving for multi-key mappings
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
      local function git_diff_current_file()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          vim.notify("No file to diff", vim.log.levels.WARN)
          return
        end

        local root_result = vim.system({ "git", "-C", vim.fs.dirname(path), "rev-parse", "--show-toplevel" }, { text = true }):wait()
        if root_result.code ~= 0 then
          vim.notify("Not inside a git repository", vim.log.levels.WARN)
          return
        end

        local root = vim.trim(root_result.stdout)
        local relpath = vim.fs.relpath(root, path) or path:gsub("^" .. vim.pesc(root .. "/"), "")
        local head_result = vim.system({ "git", "-C", root, "show", "HEAD:" .. relpath }, { text = true }):wait()
        local head_lines = head_result.code == 0 and vim.split(head_result.stdout, "\n", { plain = true }) or {}

        if head_lines[#head_lines] == "" then
          table.remove(head_lines)
        end

        local original_win = vim.fn.win_getid()
        local original_cursor = vim.api.nvim_win_get_cursor(0)
        vim.cmd("tabedit " .. vim.fn.fnameescape(path))
        local diff_tab = vim.api.nvim_get_current_tabpage()
        local current_win = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_get_current_buf()

        local head_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(head_buf, "HEAD:" .. relpath)
        vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, head_lines)
        vim.bo[head_buf].buftype = "nofile"
        vim.bo[head_buf].bufhidden = "wipe"
        vim.bo[head_buf].buflisted = false
        vim.bo[head_buf].modifiable = false
        vim.bo[head_buf].readonly = true
        vim.bo[head_buf].filetype = vim.bo[current_buf].filetype

        vim.cmd("leftabove vertical new")
        local head_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(head_win, head_buf)

        vim.cmd("diffthis")
        vim.api.nvim_set_current_win(current_win)
        vim.cmd("diffthis")
        pcall(vim.api.nvim_win_set_cursor, current_win, original_cursor)
        vim.cmd("normal! zR")
        vim.cmd("normal! zz")

        local view = vim.fn.winsaveview()
        view.topfill = vim.fn.diff_filler(view.topline)
        vim.fn.winrestview(view)

        local function cleanup_current_buf_maps()
          if vim.api.nvim_buf_is_valid(current_buf) then
            pcall(vim.keymap.del, "n", "q", { buffer = current_buf })
            pcall(vim.keymap.del, "n", "<Esc>", { buffer = current_buf })
          end
        end

        local function close_diff_tab()
          local cursor = { 1, 0 }
          if vim.api.nvim_win_is_valid(current_win) then
            cursor = vim.api.nvim_win_get_cursor(current_win)
          end

          cleanup_current_buf_maps()

          if vim.api.nvim_tabpage_is_valid(diff_tab) then
            vim.api.nvim_set_current_tabpage(diff_tab)
            pcall(vim.cmd, "tabclose")
          end

          if vim.fn.win_id2win(original_win) ~= 0 then
            vim.fn.win_gotoid(original_win)
          elseif vim.api.nvim_buf_is_valid(current_buf) then
            vim.cmd("buffer " .. current_buf)
          end

          if vim.api.nvim_get_current_buf() == current_buf then
            pcall(vim.api.nvim_win_set_cursor, 0, cursor)
            vim.cmd("normal! zz")
          end
        end

        local group = vim.api.nvim_create_augroup("GitDiffTab" .. diff_tab, { clear = true })
        vim.api.nvim_create_autocmd("TabClosed", {
          group = group,
          callback = function()
            if not vim.api.nvim_tabpage_is_valid(diff_tab) then
              cleanup_current_buf_maps()
              pcall(vim.api.nvim_del_augroup_by_id, group)
            end
          end,
          desc = "Clean up git diff tab mappings",
        })

        vim.keymap.set("n", "q", close_diff_tab, { buffer = head_buf, desc = "Close git diff" })
        vim.keymap.set("n", "<Esc>", close_diff_tab, { buffer = head_buf, desc = "Close git diff" })
        vim.keymap.set("n", "q", close_diff_tab, { buffer = current_buf, desc = "Close git diff" })
        vim.keymap.set("n", "<Esc>", close_diff_tab, { buffer = current_buf, desc = "Close git diff" })
        vim.keymap.set("n", "]h", "]c", { buffer = head_buf, desc = "Next diff hunk" })
        vim.keymap.set("n", "[h", "[c", { buffer = head_buf, desc = "Previous diff hunk" })
      end

      require("gitsigns").setup({
        signcolumn = true,
        numhl = true,
        sign_priority = 10,
        signs = {
          add = { text = "▌" },
          change = { text = "▌" },
          delete = { text = "▁" },
          topdelete = { text = "▔" },
          changedelete = { text = "▌" },
          untracked = { text = "▌" },
        },
        attach_to_untracked = true,
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
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = "Next hunk"})

          map('n', '[h', function()
            if vim.wo.diff then return '[c' end
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
          map('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = "Blame line" })
          map('n', '<leader>gd', git_diff_current_file, { desc = "Git diff current file" })

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Select hunk" })
          require("config.keyboard_layout").attach_buffer(bufnr)
        end,
      })
    end,
  },
}
