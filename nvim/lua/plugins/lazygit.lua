local function current_file_dir()
  local file = vim.api.nvim_buf_get_name(0)

  if file ~= "" then
    if vim.fn.isdirectory(file) == 1 then
      return file
    end

    return vim.fs.dirname(file)
  end

  return vim.uv.cwd() or vim.fn.getcwd()
end

local function closest_git_root()
  local start = current_file_dir()
  local root = vim.fn.systemlist({ "git", "-C", start, "rev-parse", "--show-toplevel" })

  if vim.v.shell_error == 0 and root[1] and root[1] ~= "" then
    return root[1]
  end

  return start
end

local function lazygit_file_log()
  local file = vim.trim(vim.api.nvim_buf_get_name(0))

  if file == "" then
    Snacks.lazygit.log({ cwd = closest_git_root() })
    return
  end

  Snacks.lazygit({ args = { "-f", file }, cwd = closest_git_root() })
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        configure = true,
        win = {
          on_buf = function(self)
            self:on("TermClose", function()
              vim.schedule(function()
                vim.cmd.checktime()

                local ok, gitsigns = pcall(require, "gitsigns")
                if ok then
                  gitsigns.refresh()
                end
              end)
            end, { buf = true })
          end,
        },
        config = {
          gui = { nerdFontsVersion = "3" },
          os = {
            edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
            editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
            openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})',
          },
        },
      },
    },
    keys = {
      { "<leader>gg", function() Snacks.lazygit({ cwd = closest_git_root() }) end, desc = "LazyGit" },
      { "<leader>gl", function() Snacks.lazygit.log({ cwd = closest_git_root() }) end, desc = "LazyGit log" },
      { "<leader>gf", lazygit_file_log, desc = "LazyGit file log" },
    },
  },
}
