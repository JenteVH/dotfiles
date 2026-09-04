-- Compatibility shims for plugins that lag behind current Neovim APIs.

-- Silence deprecation notices: they pile up from third-party plugins and can
-- only be fixed upstream, so the warnings are pure noise.
vim.deprecate = function() end

local function unwrap_ts_node(node)
  if type(node) ~= "table" then
    return node
  end

  local first = node.node or node[1]
  if type(first) == "table" then
    return first.node or first[1]
  end

  return first
end

local function wrap_ts_node_fn(name)
  local original = vim.treesitter and vim.treesitter[name]
  if type(original) ~= "function" or vim.g["compat_wrapped_treesitter_" .. name] then
    return
  end

  vim.g["compat_wrapped_treesitter_" .. name] = true
  vim.treesitter[name] = function(node, ...)
    return original(unwrap_ts_node(node), ...)
  end
end

-- Legacy nvim-treesitter master handlers expect match[id] to be a TSNode.
-- Neovim 0.12 passes match[id] as a TSNode list, which otherwise crashes in
-- vim.treesitter.get_node_text()/get_range() during Markdown injections.
wrap_ts_node_fn("get_node_text")
wrap_ts_node_fn("get_range")

return {}
