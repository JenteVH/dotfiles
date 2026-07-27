return {
  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local bg = normal.bg or 0x1e1e2e
      local r = math.floor(bg / 0x10000) % 0x100
      local g = math.floor(bg / 0x100) % 0x100
      local b = bg % 0x100
      local luminance = (0.299 * r) + (0.587 * g) + (0.114 * b)
      local offset = luminance < 128 and 14 or -14
      local cmp_bg = (math.max(0, math.min(255, r + offset)) * 0x10000)
        + (math.max(0, math.min(255, g + offset)) * 0x100)
        + math.max(0, math.min(255, b + offset))

      vim.api.nvim_set_hl(0, "CmpPmenu", { bg = cmp_bg, fg = normal.fg })
      vim.api.nvim_set_hl(0, "CmpBorder", { bg = cmp_bg, fg = normal.fg })

      local function compare_ai_first(entry1, entry2)
        local entry1_is_ai = entry1.source.name == "minuet"
        local entry2_is_ai = entry2.source.name == "minuet"

        if entry1_is_ai ~= entry2_is_ai then
          return entry1_is_ai
        end
      end

      local function complete_with_minuet()
        cmp.complete({
          config = {
            sources = cmp.config.sources({
              { name = "minuet" },
            }),
          },
        })
      end

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        enabled = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local name = vim.api.nvim_buf_get_name(bufnr)
          local bt = vim.bo[bufnr].buftype

          if bt == "prompt" or bt == "nofile" then
            return false
          end

          if name:match("^//kulala://") then
            return false
          end

          return true
        end,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-@>"] = cmp.mapping.complete(),
          ["<M-]>"] = cmp.mapping(complete_with_minuet, { "i" }),
          ["<CR>"] = cmp.mapping(function(fallback)
            local view = cmp.core.view
            if view:visible() and view:get_selected_entry() then
              cmp.confirm({ select = false })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "minuet", priority = 1000 },
          {
            name = "nvim_lsp",
            priority = 750,
            option = {
              ["intelephense-manual"] = {
                keyword_pattern = [[\%(\$\k*\)\|\k\+]],
              },
            },
          },
          { name = "luasnip", priority = 700 },
          { name = "path", priority = 500 },
          { name = "buffer", priority = 250, keyword_length = 3 },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare_ai_first,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            symbol_map = {},
          }),
        },
      })

      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Integrate with nvim-autopairs
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
}
