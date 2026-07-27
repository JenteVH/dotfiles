return {
  {
    "monkoose/neocodeium",
    enabled = false,
    event = "VeryLazy",
    config = function()
      local neocodeium = require("neocodeium")

      neocodeium.setup({
        manual = true,
        silent = true,
        filetypes = {
          help = false,
          gitcommit = false,
          gitrebase = false,
          ["."] = false,
          TelescopePrompt = false,
          ["dap-repl"] = false,
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "NeoCodeiumCompletionDisplayed",
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if ok then
            cmp.abort()
          end
        end,
      })

      vim.keymap.set("i", "<M-z>", function() neocodeium.cycle_or_complete() end, { desc = "NeoCodeium complete" })
      vim.keymap.set("i", "<M-a>", function() neocodeium.accept() end, { desc = "NeoCodeium accept" })
      vim.keymap.set("i", "<M-x>", function() neocodeium.clear() end, { desc = "NeoCodeium clear" })
    end,
  },
  {
    "milanglacier/minuet-ai.nvim",
    enabled = true,
    event = "VeryLazy",
    config = function()
      local function has_env(name)
        return vim.env[name] ~= nil and vim.env[name] ~= ""
      end

      local provider = "openai_compatible"
      local openai_compatible = {
        api_key = "OPENROUTER_API_KEY",
        end_point = "https://openrouter.ai/api/v1/chat/completions",
        model = "openai/gpt-5.6-luna",
        name = "OpenRouter",
        optional = {
          max_tokens = 256,
          reasoning = { effort = "none" },
          provider = {
            sort = "latency",
          },
        },
      }

      if has_env("OPENCODE_GO_API_KEY") and not has_env("OPENROUTER_API_KEY") then
        openai_compatible = {
          api_key = "OPENCODE_GO_API_KEY",
          end_point = "https://opencode.ai/zen/go/v1/chat/completions",
          model = "deepseek-v4-flash",
          name = "Opencode",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
            thinking = { type = "disabled" },
          },
        }
      end

      local duet_provider = "gemini"

      if not has_env("GEMINI_API_KEY") then
        if has_env("OPENROUTER_API_KEY") or has_env("OPENCODE_GO_API_KEY") then
          duet_provider = "openai_compatible"
        elseif has_env("OPENAI_API_KEY") then
          duet_provider = "openai"
        elseif has_env("ANTHROPIC_API_KEY") then
          duet_provider = "claude"
        end
      end

      local duet_openai_compatible = {
        api_key = "OPENROUTER_API_KEY",
        end_point = "https://openrouter.ai/api/v1/chat/completions",
        model = "google/gemini-3-flash-preview",
        name = "OpenRouter",
        optional = {
          reasoning_effort = "none",
          provider = {
            sort = "throughput",
          },
        },
      }

      if has_env("OPENCODE_GO_API_KEY") and not has_env("OPENROUTER_API_KEY") then
        duet_openai_compatible = {
          api_key = "OPENCODE_GO_API_KEY",
          end_point = "https://opencode.ai/zen/go/v1/chat/completions",
          model = "deepseek-v4-flash",
          name = "Opencode",
          optional = {
            thinking = { type = "disabled" },
          },
        }
      end

      local function select_openrouter_qwen_model()
        local minuet = require("minuet")
        local current = minuet.config.provider_options.openai_compatible.model
        local models = {
          { name = "qwen/qwen3-coder-plus", desc = "Best quality coding" },
          { name = "qwen/qwen3-coder-flash", desc = "Faster/cheaper coding" },
          { name = "qwen/qwen3-coder", desc = "Open-weight 480B coder" },
          { name = "qwen/qwen3-coder-next", desc = "Next local-dev coder" },
          { name = "qwen/qwen3-coder-30b-a3b-instruct", desc = "Smaller coder" },
        }

        vim.ui.select(models, {
          prompt = "Select Minuet OpenRouter Qwen model:",
          format_item = function(item)
            local label = item.name .. " - " .. item.desc

            if item.name == current then
              label = label .. " (current)"
            end

            return label
          end,
        }, function(choice)
          if not choice then
            return
          end

          minuet.change_model("openai_compatible:" .. choice.name)
        end)
      end

      require("minuet").setup({
        provider = provider,
        cmp = {
          enable_auto_complete = true,
        },
        n_completions = 1,
        context_window = 16000,
        throttle = 1000,
        debounce = 250,
        request_timeout = 2.5,
        notify = "warn",
        provider_options = {
          openai_compatible = openai_compatible,
          openai_fim_compatible = {
            api_key = "TERM",
            end_point = "http://localhost:11434/v1/completions",
            model = "granite4:latest",
            name = "Ollama",
            optional = {
              max_tokens = 48,
              top_p = 0.9,
            },
            template = {
              prompt = function(context_before_cursor, context_after_cursor, _)
                return "<|fim_prefix|>"
                  .. context_before_cursor
                  .. "<|fim_suffix|>"
                  .. context_after_cursor
                  .. "<|fim_middle|>"
              end,
              suffix = false,
            },
          },
        },
        virtualtext = {
          auto_trigger_ft = {},
          auto_trigger_ignore_ft = {
            "help",
            "gitcommit",
            "gitrebase",
            ".",
          },
        },
        duet = {
          provider = duet_provider,
          provider_options = {
            gemini = {
              model = "gemini-3-flash-preview",
              optional = {
                generationConfig = {
                  thinkingConfig = {
                    thinkingLevel = "minimal",
                  },
                },
              },
            },
            openai_compatible = duet_openai_compatible,
          },
        },
      })

      vim.keymap.set("n", "<leader>np", "<cmd>Minuet duet predict<cr>", { desc = "Duet predict" })
      vim.keymap.set("n", "<leader>na", "<cmd>Minuet duet apply<cr>", { desc = "Duet apply" })
      vim.keymap.set("n", "<leader>nd", "<cmd>Minuet duet dismiss<cr>", { desc = "Duet dismiss" })
      vim.keymap.set("n", "<leader>nm", select_openrouter_qwen_model, { desc = "Select Minuet model" })

      vim.api.nvim_create_user_command("MinuetQwenModel", select_openrouter_qwen_model, {})

      vim.keymap.set("i", "<M-z>", "<cmd>Minuet duet predict<cr>", { desc = "Duet predict" })
      vim.keymap.set("i", "<M-a>", "<cmd>Minuet duet apply<cr>", { desc = "Duet apply" })
      vim.keymap.set("i", "<M-x>", "<cmd>Minuet duet dismiss<cr>", { desc = "Duet dismiss" })
    end,
  },
}
