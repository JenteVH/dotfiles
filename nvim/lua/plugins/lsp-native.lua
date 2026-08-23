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

      -- Helper function to find root directory
      local function find_root(fname, patterns)
        -- Handle both file paths and buffer numbers
        local filename = fname
        if type(fname) == "number" then
          filename = vim.api.nvim_buf_get_name(fname)
        end

        local path = vim.fs.dirname(filename)
        local found = vim.fs.find(patterns, {
          path = path,
          upward = true,
          stop = vim.fn.expand("~"),
        })[1]

        if found then
          return vim.fs.dirname(found)
        end
        return vim.fn.getcwd()
      end

      -- Custom :LspRestart command.
      -- vim.lsp.stop_client() is async, so we must wait until each client has
      -- fully exited before reattaching; otherwise vim.lsp.start() reuses the
      -- dying client and the buffer ends up with no LSP. Reattach by re-firing
      -- FileType, which both vim.lsp.enable() (group nvim.lsp.enable) and the
      -- manual PHP/Intelephense autocmd listen on.
      vim.api.nvim_create_user_command("LspRestart", function()
        local clients = vim.lsp.get_clients()
        if #clients == 0 then
          vim.notify("LspRestart: no active LSP clients", vim.log.levels.INFO)
          return
        end

        -- Remember the buffers each client served, then force-stop it.
        local pending = {} -- client_id -> attached buffers
        for _, client in ipairs(clients) do
          pending[client.id] = vim.lsp.get_buffers_by_client_id(client.id)
          vim.lsp.stop_client(client.id, true) -- force = fast exit
        end

        -- Poll until clients have exited (removed from the registry), then
        -- re-trigger auto-attach for their buffers with a fresh client.
        local timer = assert((vim.uv or vim.loop).new_timer())
        local ticks = 0
        timer:start(
          150,
          100,
          vim.schedule_wrap(function()
            ticks = ticks + 1
            local give_up = ticks > 50 -- ~5s safety cap
            for id, bufs in pairs(pending) do
              if give_up or vim.lsp.get_client_by_id(id) == nil then
                for _, buf in ipairs(bufs) do
                  if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
                    vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
                  end
                end
                pending[id] = nil
              end
            end
            if next(pending) == nil and not timer:is_closing() then
              timer:stop()
              timer:close()
            end
          end)
        )
      end, { desc = "Restart all LSP clients" })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          current_line = true,
          prefix = "●",
        },
        underline = true,
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

      local function apply_source_action(kind)
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { kind },
          },
        })
      end

      local function add_missing_imports()
        local source_import_actions = {
          go = "source.organizeImports",
          javascript = "source.addMissingImports.ts",
          javascriptreact = "source.addMissingImports.ts",
          typescript = "source.addMissingImports.ts",
          typescriptreact = "source.addMissingImports.ts",
        }

        local action = source_import_actions[vim.bo.filetype]
        if action then
          apply_source_action(action)
        else
          vim.lsp.buf.code_action()
        end
      end

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
        buf_set_keymap("n", "<leader>lI", add_missing_imports, "Add missing imports")
        buf_set_keymap("n", "<leader>lO", function()
          apply_source_action("source.organizeImports")
        end, "Organize imports")
        buf_set_keymap("n", "gr", vim.lsp.buf.references, "Find references")
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      local pyright_on_attach = vim.lsp.config.pyright and vim.lsp.config.pyright.on_attach

      vim.lsp.config("pyright", {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          if pyright_on_attach then
            pyright_on_attach(client, bufnr)
          end
          on_attach(client, bufnr)
        end,
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
            suggest = {
              autoImports = true,
            },
            preferences = {
              includePackageJsonAutoImports = "on",
            },
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
            suggest = {
              autoImports = true,
            },
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function(args)
          local root_dir = vim.fs.root(args.buf, { ".git" })
            or vim.fs.root(args.buf, { "composer.json", "composer.lock", ".php-cs-fixer.php", "phpunit.xml", "phpunit.xml.dist" })

          if not root_dir then
            return
          end

          vim.lsp.start({
            name = "intelephense-manual",
            cmd = { "intelephense", "--stdio" },
            root_dir = root_dir,
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              intelephense = {
                files = {
                  exclude = {
                    "**/.git/**",
                    "**/.svn/**",
                    "**/.hg/**",
                    "**/CVS/**",
                    "**/.DS_Store/**",
                    "**/node_modules/**",
                    "**/bower_components/**",
                    "**/vendor/hinscha/**",
                  },
                },
              },
            },
          })
        end,
      })

      vim.lsp.config("laravel_ls", {
        workspace_required = true,
        root_markers = {
          "artisan",
        },
      })

      local rust_analyzer_on_attach = vim.lsp.config.rust_analyzer and vim.lsp.config.rust_analyzer.on_attach

      vim.lsp.config("rust_analyzer", {
        on_attach = function(client, bufnr)
          if rust_analyzer_on_attach then
            rust_analyzer_on_attach(client, bufnr)
          end
          on_attach(client, bufnr)
        end,
        root_markers = { { "Cargo.toml" }, { ".git" } },
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            check = {
              command = "clippy",
            },
          },
        },
      })

      vim.lsp.config("clangd", {
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clang-tidy",
          ".git",
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--pch-storage=memory",
          "--inlay-hints",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
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
        "laravel_ls",
        "rust_analyzer",
        "clangd",
      })
    end,
  },
}
