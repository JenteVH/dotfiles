return {
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
        },
        severity_sort = true,
        float = {
          source = "always",
          border = "rounded",
        },
      })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
      vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic in float" })
      vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Set diagnostic to loclist" })

      vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#313244" })
      vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#313244" })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#313244", underline = true })

      local on_attach = function(client, bufnr)
        local function buf_set_keymap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        buf_set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        buf_set_keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        buf_set_keymap("n", "K", vim.lsp.buf.hover, "Hover documentation")
        buf_set_keymap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        buf_set_keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        buf_set_keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        buf_set_keymap("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")
        buf_set_keymap("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        buf_set_keymap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        buf_set_keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        buf_set_keymap("n", "gr", vim.lsp.buf.references, "Find references")
        buf_set_keymap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format document")
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      vim.lsp.config("pyright", {
        root_markers = {
          "pyrightconfig.json",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          ".git",
        },
        settings = {
          python = {
            analysis = {
              extraPaths = {},
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              autoImportCompletions = true,
              reportMissingImports = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        root_markers = {
          ".luarc.json",
          ".luarc.jsonc",
          ".luacheckrc",
          ".stylua.toml",
          "stylua.toml",
          "selene.toml",
          "selene.yml",
          ".git",
        },
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config("bashls", {
        root_markers = { ".git" },
      })

      vim.lsp.config("yamlls", {
        root_markers = { ".git" },
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        root_markers = { "package.json", ".git" },
        init_options = {
          provideFormatter = true,
        },
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("html", {
        root_markers = { ".git" },
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          provideFormatter = true,
        },
      })

      vim.lsp.config("cssls", {
        root_markers = { ".git" },
        settings = {
          css = {
            validate = true,
          },
          less = {
            validate = true,
          },
          scss = {
            validate = true,
          },
        },
      })

      vim.lsp.config("dockerls", {
        root_markers = {
          "Dockerfile",
          "dockerfile",
          "Containerfile",
          ".git",
        },
      })

      vim.lsp.config("vtsls", {
        root_markers = {
          "package.json",
          "tsconfig.json",
          "jsconfig.json",
          ".git",
        },
        settings = {
          vtsls = {
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        root_markers = {
          "go.work",
          "go.mod",
          ".git",
        },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config("intelephense", {
        root_markers = {
          "composer.json",
          "composer.lock",
          ".php-cs-fixer.php",
          "phpunit.xml",
          "phpunit.xml.dist",
          ".git",
        },
      })

      vim.lsp.config("rust_analyzer", {
        root_markers = { "Cargo.toml", ".git" },
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })

      vim.lsp.enable({
        "pyright",
        "lua_ls",
        "bashls",
        "yamlls",
        "jsonls",
        "html",
        "cssls",
        "dockerls",
        "vtsls",
        "gopls",
        "intelephense",
        "rust_analyzer",
      })
    end,
  },
}
