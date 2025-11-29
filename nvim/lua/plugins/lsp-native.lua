-- Native LSP configuration using vim.lsp.config (Neovim 0.11+)
return {
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    name = "lsp-native-config",
    dir = vim.fn.stdpath("config"),
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Get capabilities from nvim-cmp
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

      -- Diagnostic configuration
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

      -- Diagnostic keymaps
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
      vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show diagnostic in float" })
      vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Set diagnostic to loclist" })

      -- LSP attach function for keymaps and dynamic configuration
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- LSP keymaps
        buf_set_keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        buf_set_keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        buf_set_keymap("n", "K", vim.lsp.buf.hover, "Hover documentation")
        buf_set_keymap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        buf_set_keymap("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
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

        -- For Pyright, just ensure it's using the right root directory
      end

      -- Python: Pyright configuration
      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_dir = function(fname)
          local root = find_root(fname, {
            "pyrightconfig.json",  -- Prioritize pyrightconfig.json
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git",
          })
          -- Ensure we return a valid directory
          if root and vim.fn.isdirectory(root) == 1 then
            return root
          end
          return vim.fn.getcwd()
        end,
        on_new_config = function(new_config, new_root_dir)
          -- Set the working directory for pyright-langserver to the project root
          new_config.cmd_cwd = new_root_dir
        end,
        on_init = function(client)
          -- Ensure client knows the workspace root
          if client.config.root_dir then
            client.config.workspace_folders = {
              {
                uri = vim.uri_from_fname(client.config.root_dir),
                name = vim.fn.fnamemodify(client.config.root_dir, ":t"),
              }
            }
          end
        end,
        settings = {
          python = {
            analysis = {
              extraPaths = {
                "/app/inspection",
                "/app/sales",
                "/app/asset",
                "/app/api_gateway",
                "/app/backend",
              },
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              reportMissingImports = true,
            },
          },
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Python: Only Pyright is used (pylsp disabled to avoid conflicts)

      -- Lua LSP configuration
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_dir = function(fname)
          return find_root(fname, {
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
          })
        end,
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
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Bash LSP
      vim.lsp.config.bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_dir = function(fname)
          return find_root(fname, { ".git" })
        end,
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- YAML LSP
      vim.lsp.config.yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose", "yml" },
        root_dir = function(fname)
          return find_root(fname, { ".git" })
        end,
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
            },
          },
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- JSON LSP
      vim.lsp.config.jsonls = {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_dir = function(fname)
          return find_root(fname, { "package.json", ".git" })
        end,
        init_options = {
          provideFormatter = true,
        },
        settings = {
          json = {
            validate = { enable = true },
          },
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- HTML LSP
      vim.lsp.config.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "htm" },
        root_dir = function(fname)
          return find_root(fname, { ".git" })
        end,
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          provideFormatter = true,
        },
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- CSS LSP
      vim.lsp.config.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_dir = function(fname)
          return find_root(fname, { ".git" })
        end,
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
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Docker LSP
      vim.lsp.config.dockerls = {
        cmd = { "docker-langserver", "--stdio" },
        filetypes = { "dockerfile" },
        root_dir = function(fname)
          return find_root(fname, {
            "Dockerfile",
            "dockerfile",
            "Containerfile",
            ".git",
          })
        end,
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- TypeScript/JavaScript LSP (vtsls)
      vim.lsp.config.vtsls = {
        cmd = { "vtsls", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        root_dir = function(fname)
          return find_root(fname, {
            "package.json",
            "tsconfig.json",
            "jsconfig.json",
            ".git",
          })
        end,
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
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Go LSP
      vim.lsp.config.gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = function(fname)
          return find_root(fname, {
            "go.work",
            "go.mod",
            ".git",
          })
        end,
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
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Auto-start LSP for configured filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "lua", "sh", "bash", "yaml", "yml", "json", "jsonc", "html", "htm", "css", "scss", "less", "dockerfile", "javascript", "javascriptreact", "typescript", "typescriptreact", "go", "gomod", "gowork", "gotmpl" },
        callback = function(args)
          local ft = vim.bo[args.buf].filetype

          -- Map filetypes to LSP servers
          local ft_to_lsp = {
            python = { "pyright" },  -- Only Pyright (pylsp disabled to avoid conflicts)
            lua = { "lua_ls" },
            sh = { "bashls" },
            bash = { "bashls" },
            yaml = { "yamlls" },
            yml = { "yamlls" },
            json = { "jsonls" },
            jsonc = { "jsonls" },
            html = { "html" },
            htm = { "html" },
            css = { "cssls" },
            scss = { "cssls" },
            less = { "cssls" },
            dockerfile = { "dockerls" },
            javascript = { "vtsls" },
            javascriptreact = { "vtsls" },
            typescript = { "vtsls" },
            typescriptreact = { "vtsls" },
            go = { "gopls" },
            gomod = { "gopls" },
            gowork = { "gopls" },
            gotmpl = { "gopls" },
          }

          local servers = ft_to_lsp[ft]
          if servers then
            for _, server in ipairs(servers) do
              -- Start the LSP server using vim.lsp.start with the config and buffer
              local config = vim.tbl_deep_extend("force", {}, vim.lsp.config[server])
              -- Resolve root_dir if it's a function
              if type(config.root_dir) == "function" then
                config.root_dir = config.root_dir(vim.api.nvim_buf_get_name(args.buf))
              end
              -- Set cmd_cwd to the resolved root_dir so pyright-langserver starts there
              if config.root_dir then
                config.cmd_cwd = config.root_dir
              end
              vim.lsp.start(config, { bufnr = args.buf })
            end
          end
        end,
      })
    end,
  },
}