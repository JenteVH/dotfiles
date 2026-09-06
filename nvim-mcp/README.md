# Neovim MCP bridge

Control an already-running Neovim session from Codex or any local MCP stdio client.
Uses the official Python MCP SDK and Neovim's MessagePack RPC API. No Neovim plugin,
model API key, HTTP service, or editor restart is required. Neovim 0.11+ and Python 3.11+.

## Use

Once the MCP server is loaded in your client, ask:

> List my Neovim sessions, then inspect the one in thelowlands.
> Read my current buffer and diagnostics. Fix the issue, leaving the edit unsaved.
> Open this file in a vertical split and move to line 42.

`list_sessions` returns socket paths, PIDs, working directories and current buffers.
Pass the intended socket on subsequent calls. There is no automatic choice between
multiple sessions. If launched from Neovim's terminal, inherited `NVIM` targets that
editor; `NVIM_MCP_SOCKET` takes precedence. An explicit tool `socket` overrides both.
Socket connections are re-established per call, so the server can discover editors
started after the MCP client.

Show sessions from a terminal:

```sh
~/Documents/dotfiles/bin/nvim-mcp --list-sessions
```

Neovim normally creates a socket automatically. Find yours with `:echo v:servername`.
For a predictable custom socket, launch `nvim --listen /tmp/nvim-main.sock`, or use
`:call serverstart('/tmp/nvim-main.sock')` in an existing session. Use an explicit
socket tool argument or `NVIM_MCP_SOCKET` for paths outside the discovery locations.

## Tools

| Tool | Purpose |
| --- | --- |
| `list_sessions` | Discover sessions, including errors for stale/busy sockets |
| `get_state` | Buffers, windows, tabs, cursor, mode, visual anchor |
| `read_buffer` | Paginated buffer text, including unsaved edits, and changedtick |
| `get_diagnostics` | Current-buffer or all-buffer diagnostics |
| `replace_lines` | Atomic, undoable edit guarded by the previous changedtick |
| `open_file` | Open in current window, split, vertical split, or tab |
| `set_cursor` | Focus window and navigate |
| `save_buffer` | Explicit disk save guarded by changedtick |
| `send_keys` | Queue keys with Neovim notation and your mappings |
| `run_command` | Ex/Vimscript commands, with captured output |
| `run_lua` | Full Lua, Neovim API and plugin access |

Lines are 1-based. `replace_lines` uses an exclusive end: replace line 3 with
`start_line=3,end_line=4`; insert before line 3 with `3,3`; delete using `lines=[]`.
Cursor and diagnostic columns are 0-based UTF-8 byte offsets. Read before editing
and pass the returned explicit buffer ID and changedtick. Ordinary edits do not
save; user autocommands/plugins retain their normal behavior. `undo` reverses a
structured edit. Your Colemak or other key mappings apply to `send_keys`; use
structured navigation or `normal!` for layout-independent actions.

## Install / rebuild

From this directory:

```sh
uv sync --frozen
chmod +x ../bin/nvim-mcp
```

The launcher uses the installed virtual environment directly, with no downloads
on startup. `uv.lock` pins dependencies. Re-run `uv sync --frozen` after a Python
upgrade if the virtual environment needs rebuilding.

Codex registration:

```sh
codex mcp add neovim -- /home/jente/Documents/dotfiles/bin/nvim-mcp
```

Then start a new Codex session or reload MCP servers. In the CLI, `/mcp` shows
loaded servers. Equivalent `~/.codex/config.toml` entry:

```toml
[mcp_servers.neovim]
command = "/home/jente/Documents/dotfiles/bin/nvim-mcp"
```

Other MCP clients that support local stdio can use:

```json
{
  "mcpServers": {
    "neovim": {
      "command": "/home/jente/Documents/dotfiles/bin/nvim-mcp"
    }
  }
}
```

Adjust absolute paths if moving the dotfiles. Hosted clients need a local bridge
capability; this server does not publish a network endpoint.

## Behavior and troubleshooting

Only Unix sockets owned by the current user are accepted. Commands, Lua and key
input provide full editor access, including shell execution, just as interactive
Neovim does. Connect trusted MCP clients. No separate approval system is installed;
your MCP client's tool permissions still apply.

Requests time out after five seconds (discovery uses 0.7 seconds per socket).
Timeouts do not cancel commands already running in Neovim. Inspect state before
retrying a mutation. Key input is queued asynchronously; inspect state afterward.
Prompts or a busy editor can delay responses; finish the prompt or interrupt the
operation in Neovim. `Operation not permitted` usually means the client sandbox
blocks local sockets; run the MCP process with local socket access.

To disconnect Codex: `codex mcp remove neovim`. This leaves Neovim untouched.

## Verification

```sh
.venv/bin/python -m unittest -v test_integration
```

Tests launch a disposable headless Neovim and a real MCP stdio client. They cover
discovery, tool schemas, state, edits, stale edit/save rejection, undo/redo, disk
saving, navigation, keys, Lua, diagnostics, split opening with special path
characters, unloaded buffers, invalid inputs, and ambiguous-session handling.

References: [Neovim API](https://neovim.io/doc/user/api/),
[Python MCP SDK](https://github.com/modelcontextprotocol/python-sdk),
[Codex MCP configuration](https://developers.openai.com/codex/mcp).
