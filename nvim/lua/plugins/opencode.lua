return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      local current_edit_request_id
      local diff_tabpage
      local diff_temp_paths
      local is_permission_request_open = false
      local replied_permission_request_ids = {}
      local opencode_terminal_bufnr
      local opencode_terminal_winid
      local opencode_previous_bufnr

      local function cleanup_diff_state()
        if diff_temp_paths then
          for _, path in ipairs(diff_temp_paths) do
            if path and vim.uv.fs_stat(path) then
              pcall(vim.uv.fs_unlink, path)
            end
          end
        end

        current_edit_request_id = nil
        diff_tabpage = nil
        diff_temp_paths = nil
      end

      local function close_diff_tab()
        local tabpage = diff_tabpage

        if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then
          cleanup_diff_state()
          return true
        end

        local ok = pcall(vim.api.nvim_set_current_tabpage, tabpage)
        if ok then
          ok = pcall(vim.cmd, "tabclose")
        end

        if not ok and vim.api.nvim_tabpage_is_valid(tabpage) then
          return false
        end

        cleanup_diff_state()
        return true
      end

      local function normalize_patch_path(path)
        path = path:gsub("\t.*$", "")
        path = path:gsub("^a/", "")
        path = path:gsub("^b/", "")
        return vim.fs.normalize(path)
      end

      local function patch_path_matches(path, filepath)
        if not path or path == "/dev/null" then
          return false
        end

        local normalized_path = normalize_patch_path(path)
        local normalized_filepath = vim.fs.normalize(filepath)

        if normalized_path == normalized_filepath then
          return true
        end

        return #normalized_path < #normalized_filepath
          and normalized_filepath:sub(-#normalized_path) == normalized_path
          and normalized_filepath:sub(-#normalized_path - 1, -#normalized_path - 1) == "/"
      end

      local function section_matches_filepath(section, filepath)
        for _, line in ipairs(section) do
          local old_path = line:match("^%-%-%- (.+)$")
          if patch_path_matches(old_path, filepath) then
            return true
          end

          local new_path = line:match("^%+%+%+ (.+)$")
          if patch_path_matches(new_path, filepath) then
            return true
          end

          local left_path, right_path = line:match("^diff %-%-git a/(.-) b/(.-)$")
          if patch_path_matches(left_path, filepath) or patch_path_matches(right_path, filepath) then
            return true
          end
        end

        return false
      end

      local function extract_file_patch(diff, filepath)
        local lines = vim.split(diff, "\n", { plain = true })
        local has_explicit_sections = false

        for _, line in ipairs(lines) do
          if line:match("^diff %-%-git ") or line:match("^Index: ") then
            has_explicit_sections = true
            break
          end
        end

        local sections = {}
        local current_section = {}

        for index, line in ipairs(lines) do
          local next_line = lines[index + 1]
          local starts_new_section = false

          if has_explicit_sections then
            starts_new_section = line:match("^diff %-%-git ") or line:match("^Index: ")
          else
            starts_new_section = line:match("^%-%-%- ") and next_line and next_line:match("^%+%+%+ ")
          end

          if starts_new_section and #current_section > 0 then
            table.insert(sections, current_section)
            current_section = {}
          end

          table.insert(current_section, line)
        end

        if #current_section > 0 then
          table.insert(sections, current_section)
        end

        if #sections <= 1 then
          return diff
        end

        local target_sections = {}
        for _, section in ipairs(sections) do
          if section_matches_filepath(section, filepath) then
            vim.list_extend(target_sections, section)
          end
        end

        if vim.tbl_isempty(target_sections) then
          return nil
        end

        return table.concat(target_sections, "\n")
      end

      local function permit_permission(url, request_id, reply)
        if not url then
          vim.notify("Failed to reply to opencode permission: missing server URL", vim.log.levels.ERROR, {
            title = "opencode",
          })
          return
        end

        require("opencode.server").new(url)
          :next(function(server)
            return server:permit(request_id, reply)
          end)
          :catch(function(msg)
            if msg then
              vim.notify(msg, vim.log.levels.ERROR, { title = "opencode" })
            end
          end)
      end

      local function fallback_edit_prompt(url, request_id, message)
        vim.notify(message, vim.log.levels.WARN, { title = "opencode" })

        vim.ui.select({ "Once", "Reject" }, {
          prompt = "Permit opencode edit without a diff preview?: ",
        }, function(choice)
          if choice then
            permit_permission(url, request_id, choice:lower())
          end
        end)
      end

      local function set_diff_keymaps(bufnr, url, request_id)
        vim.keymap.set("n", "dp", function()
          if current_edit_request_id then
            current_edit_request_id = nil
            permit_permission(url, request_id, "reject")
          end
          return "dp"
        end, { buffer = bufnr, desc = "Accept opencode edit hunk", expr = true })

        vim.keymap.set("n", "do", function()
          if current_edit_request_id then
            current_edit_request_id = nil
            permit_permission(url, request_id, "reject")
          end
          return "do"
        end, { buffer = bufnr, desc = "Reject opencode edit hunk", expr = true })

        vim.keymap.set("n", "da", function()
          permit_permission(url, request_id, "once")
        end, { buffer = bufnr, desc = "Accept opencode edit" })

        vim.keymap.set("n", "dr", function()
          permit_permission(url, request_id, "reject")
        end, { buffer = bufnr, desc = "Reject opencode edit" })

        vim.keymap.set("n", "<leader>oa", function()
          permit_permission(url, request_id, "once")
        end, { buffer = bufnr, desc = "Accept opencode edit" })

        vim.keymap.set("n", "<leader>or", function()
          permit_permission(url, request_id, "reject")
        end, { buffer = bufnr, desc = "Reject opencode edit" })

        vim.keymap.set("n", "q", function()
          if not close_diff_tab() then
            vim.notify("Close or hide modified diff buffers before closing the opencode diff tab", vim.log.levels.WARN, {
              title = "opencode",
            })
          end
        end, { buffer = bufnr, desc = "Close opencode edit diff" })
      end

      local function open_edit_diff(url, event)
        local metadata = event.properties.metadata or {}
        local filepath = metadata.filepath
        local diff = metadata.diff

        if not filepath or not diff then
          fallback_edit_prompt(url, event.properties.id, "Failed to render opencode edit preview: missing diff metadata")
          return
        end

        if not close_diff_tab() then
          vim.notify("Close the existing opencode diff tab before opening a new edit preview", vim.log.levels.WARN, {
            title = "opencode",
          })
          return
        end

        local file_patch = extract_file_patch(diff, filepath)
        if not file_patch then
          fallback_edit_prompt(url, event.properties.id, "Failed to isolate the requested file from the opencode edit diff")
          return
        end

        local patch_filepath = vim.fn.tempname() .. ".patch"
        if vim.fn.writefile(vim.split(file_patch, "\n", { plain = true }), patch_filepath) ~= 0 then
          fallback_edit_prompt(url, event.properties.id, "Failed to write a temporary patch for the opencode edit preview")
          return
        end

        diff_temp_paths = { patch_filepath }

        local source_filepath = filepath
        if not vim.uv.fs_stat(filepath) then
          source_filepath = vim.fn.tempname()
          if vim.fn.writefile({}, source_filepath) ~= 0 then
            cleanup_diff_state()
            fallback_edit_prompt(url, event.properties.id, "Failed to prepare a temporary file for the opencode edit preview")
            return
          end

          table.insert(diff_temp_paths, source_filepath)
        end

        local patched_filepath = vim.fn.tempname()
        table.insert(diff_temp_paths, patched_filepath)

        local result = vim.system({ "patch", "--batch", "--silent", "-o", patched_filepath, source_filepath, patch_filepath }, { text = true }):wait()
        if result.code ~= 0 or not vim.uv.fs_stat(patched_filepath) then
          local stderr = result.stderr and result.stderr ~= "" and result.stderr or "patch could not render the proposed edit"
          cleanup_diff_state()
          fallback_edit_prompt(url, event.properties.id, "Failed to render opencode edit preview: " .. stderr)
          return
        end

        local ok = pcall(vim.cmd, "tabedit " .. vim.fn.fnameescape(filepath))
        if not ok then
          cleanup_diff_state()
          fallback_edit_prompt(url, event.properties.id, "Failed to open the target file for the opencode edit preview")
          return
        end

        local tabpage = vim.api.nvim_get_current_tabpage()
        local original_buf = vim.api.nvim_get_current_buf()

        ok = pcall(vim.cmd, "silent vertical diffsplit " .. vim.fn.fnameescape(patched_filepath))
        if not ok then
          pcall(vim.cmd, "tabclose")
          cleanup_diff_state()
          fallback_edit_prompt(url, event.properties.id, "Failed to open the opencode edit diff preview")
          return
        end

        local patched_buf = vim.api.nvim_get_current_buf()

        current_edit_request_id = event.properties.id
        diff_tabpage = tabpage

        set_diff_keymaps(original_buf, url, event.properties.id)
        set_diff_keymaps(patched_buf, url, event.properties.id)
      end

      local function has_opencode_terminal_buffer()
        return opencode_terminal_bufnr and vim.api.nvim_buf_is_valid(opencode_terminal_bufnr)
      end

      local function is_opencode_terminal_focused()
        return has_opencode_terminal_buffer() and vim.api.nvim_get_current_buf() == opencode_terminal_bufnr
      end

      local function start_opencode_terminal_mode()
        if is_opencode_terminal_focused() then
          vim.cmd("startinsert")
        end
      end

      local function find_opencode_terminal_winid()
        if not has_opencode_terminal_buffer() then
          return nil
        end

        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == opencode_terminal_bufnr then
            return winid
          end
        end

        return nil
      end

      local function open_opencode_terminal_split()
        vim.cmd("botright vertical 80split")
        opencode_terminal_winid = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_buf(opencode_terminal_bufnr)
        start_opencode_terminal_mode()
      end

      local function show_opencode_terminal()
        local current_bufnr = vim.api.nvim_get_current_buf()

        if has_opencode_terminal_buffer() then
          local winid = find_opencode_terminal_winid()

          if current_bufnr ~= opencode_terminal_bufnr then
            opencode_previous_bufnr = current_bufnr
          end

          if winid then
            opencode_terminal_winid = winid
            vim.api.nvim_set_current_win(winid)
          else
            open_opencode_terminal_split()
          end

          start_opencode_terminal_mode()

          return
        end

        opencode_previous_bufnr = current_bufnr
        opencode_terminal_bufnr = vim.api.nvim_create_buf(false, false)
        vim.bo[opencode_terminal_bufnr].bufhidden = "hide"
        vim.bo[opencode_terminal_bufnr].swapfile = false

        open_opencode_terminal_split()

        vim.fn.jobstart("opencode --port", {
          term = true,
          on_exit = function()
            opencode_terminal_bufnr = nil
            opencode_terminal_winid = nil
          end,
        })
      end

      local function hide_opencode_terminal()
        local winid = opencode_terminal_winid or find_opencode_terminal_winid()

        if winid and vim.api.nvim_win_is_valid(winid) then
          pcall(vim.api.nvim_win_close, winid, true)
          opencode_terminal_winid = nil
          return
        end

        if opencode_previous_bufnr
          and vim.api.nvim_buf_is_valid(opencode_previous_bufnr)
          and opencode_previous_bufnr ~= opencode_terminal_bufnr
        then
          vim.api.nvim_set_current_buf(opencode_previous_bufnr)
          return
        end

        pcall(vim.cmd, "bprevious")
      end

      local function toggle_opencode_terminal()
        if has_opencode_terminal_buffer() and vim.api.nvim_get_current_buf() == opencode_terminal_bufnr then
          hide_opencode_terminal()
        else
          show_opencode_terminal()
        end
      end

      local function stop_opencode_terminal()
        local bufnr = opencode_terminal_bufnr
        local job_id

        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          job_id = vim.b[bufnr].terminal_job_id
        end

        if job_id then
          vim.fn.jobstop(job_id)
        end

        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end

        opencode_terminal_bufnr = nil
        opencode_terminal_winid = nil
      end

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = show_opencode_terminal,
          stop = stop_opencode_terminal,
          toggle = toggle_opencode_terminal,
        },
        events = {
          reload = true,
          permissions = {
            enabled = false,
          },
        },
      }

      vim.o.autoread = true

      local function checktime_after_opencode_edit()
        for _, delay_ms in ipairs({ 50, 250, 1000 }) do
          vim.defer_fn(function()
            pcall(vim.cmd, "checktime")
          end, delay_ms)
        end
      end

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("OpenCodeReload", { clear = true }),
        pattern = "OpencodeEvent:file.edited",
        callback = checktime_after_opencode_edit,
        desc = "Reload buffers edited by opencode",
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("OpenCodeQuitCleanup", { clear = true }),
        callback = stop_opencode_terminal,
        desc = "Stop opencode terminal before exiting Neovim",
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = vim.api.nvim_create_augroup("OpenCodeTerminalMode", { clear = true }),
        callback = start_opencode_terminal_mode,
        desc = "Start terminal mode when focusing opencode",
      })

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("OpenCodePermissions", { clear = true }),
        pattern = { "OpencodeEvent:permission.asked", "OpencodeEvent:permission.replied" },
        callback = function(args)
          local event = args.data.event
          local url = args.data.url

          if event.type == "permission.asked" then
            if is_opencode_terminal_focused() then
              return
            end

            if replied_permission_request_ids[event.properties.id] then
              return
            end

            if event.properties.permission == "edit" then
              open_edit_diff(url, event)
            end
          elseif event.type == "permission.replied" then
            replied_permission_request_ids[event.properties.requestID] = true

            if current_edit_request_id == event.properties.requestID then
              close_diff_tab()
            elseif is_permission_request_open then
              is_permission_request_open = false
            end
          end
        end,
        desc = "Handle opencode permission events",
      })

      vim.api.nvim_create_autocmd("TabClosed", {
        group = vim.api.nvim_create_augroup("OpenCodeDiffCleanup", { clear = true }),
        callback = function()
          if diff_tabpage and not vim.api.nvim_tabpage_is_valid(diff_tabpage) then
            cleanup_diff_state()
          end
        end,
        desc = "Clean up temporary opencode diff files",
      })

      vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask OpenCode" })
      vim.keymap.set("n", "<leader>ou", function() vim.fn.jobstart({ "ollama", "run", "opencode" }, { style = "floating" }) end, { desc = "Start Ollama opencode model" })
      vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "OpenCode actions" })
      vim.keymap.set("n", "<leader>ot", toggle_opencode_terminal, { desc = "Toggle OpenCode" })

      vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end, { desc = "Add range to OpenCode", expr = true })
      vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to OpenCode", expr = true })
    end,
  },
}
