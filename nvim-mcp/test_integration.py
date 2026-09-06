"""Real MCP client -> stdio bridge -> disposable Neovim integration tests."""
import asyncio
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

import server


class BridgeTests(unittest.IsolatedAsyncioTestCase):
    async def test_end_to_end(self):
        with tempfile.TemporaryDirectory(prefix="nvim-mcp-test-") as directory:
            socket = str(Path(directory) / "editor.sock")
            file = Path(directory) / "file with ' quote | bar.txt"
            file.write_text("alpha\nbeta\n")
            with open(Path(directory) / "nvim.log", "w+") as log:
                proc = subprocess.Popen(
                    ["nvim", "--headless", "--clean", "--listen", socket, "-n", str(file)],
                    stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                )
                try:
                    for _ in range(100):
                        if Path(socket).exists():
                            break
                        if proc.poll() is not None:
                            log.seek(0)
                            self.fail(log.read())
                        await asyncio.sleep(0.02)
                    self.assertTrue(Path(socket).exists(), "Neovim socket was not created")
                    params = StdioServerParameters(
                        command=sys.executable, args=[str(Path(server.__file__))],
                        env={**os.environ, "NVIM_MCP_SOCKET": socket},
                    )
                    async with stdio_client(params) as (read, write):
                        async with ClientSession(read, write) as client:
                            await client.initialize()
                            catalog = await client.list_tools()
                            self.assertEqual(len(catalog.tools), 11)
                            self.assertTrue(next(t for t in catalog.tools if t.name == "read_buffer").annotations.readOnlyHint)

                            async def call(name, **arguments):
                                result = await client.call_tool(name, {"socket": socket, **arguments})
                                self.assertFalse(result.isError, str(result.content))
                                if result.structuredContent is not None:
                                    data = result.structuredContent
                                    return data.get("result", data)
                                if not result.content:
                                    return None
                                return json.loads(result.content[0].text)

                            sessions = await client.call_tool("list_sessions", {})
                            self.assertFalse(sessions.isError)
                            self.assertIn(socket, str(sessions))
                            state = await call("get_state")
                            self.assertEqual(state["pid"], proc.pid)
                            original = await call("read_buffer")
                            b = original["buffer"]
                            self.assertEqual(original["lines"], ["alpha", "beta"])
                            edited = await call("replace_lines", buffer=b, start_line=2,
                                                end_line=3, lines=["βeta", "gamma"],
                                                changedtick=original["changedtick"])
                            self.assertTrue(edited["modified"])
                            self.assertEqual(file.read_text(), "alpha\nbeta\n")
                            stale = await client.call_tool("replace_lines", dict(socket=socket,
                                buffer=b, start_line=1, end_line=2, lines=["wrong"],
                                changedtick=original["changedtick"]))
                            self.assertTrue(stale.isError)
                            await call("run_command", command="undo")
                            self.assertEqual((await call("read_buffer"))["lines"], ["alpha", "beta"])
                            await call("run_command", command="redo")
                            current = await call("read_buffer", limit=1)
                            self.assertTrue(current["truncated"])
                            await call("save_buffer", buffer=b, changedtick=current["changedtick"])
                            self.assertEqual(file.read_text(), "alpha\nβeta\ngamma\n")
                            stale_save = await client.call_tool("save_buffer", dict(socket=socket,
                                buffer=b, changedtick=original["changedtick"]))
                            self.assertTrue(stale_save.isError)
                            pos = await call("set_cursor", line=2, column=2)
                            self.assertEqual(pos["cursor"], [2, 2])
                            await call("send_keys", keys="<Esc>gg")
                            for _ in range(30):
                                state = await call("get_state")
                                win = next(w for w in state["windows"] if w["window"] == state["current_window"])
                                if win["cursor"][0] == 1:
                                    break
                                await asyncio.sleep(0.02)
                            self.assertEqual(win["cursor"][0], 1)
                            lua = await call("run_lua", code="local x = ...; return {value=x}", args=["ok"])
                            self.assertEqual(lua, {"value": "ok"})
                            await call("run_lua", code="vim.diagnostic.set(vim.api.nvim_create_namespace('mcp-test'), 0, {{lnum=0,col=0,message='test diagnostic',severity=1}})")
                            diagnostics = await call("get_diagnostics", buffer=-1)
                            self.assertEqual(diagnostics["diagnostics"][0]["message"], "test diagnostic")
                            await call("open_file", path=str(file), layout="vsplit")
                            self.assertEqual(len((await call("get_state"))["windows"]), 2)
                            # Unloaded buffers must not prevent inspection of the session.
                            await call("run_lua", code="vim.fn.bufadd('unloaded-example.txt')")
                            self.assertGreaterEqual(len((await call("get_state"))["buffers"]), 2)
                            bad = await client.call_tool("read_buffer", {"socket": socket, "limit": 0})
                            self.assertTrue(bad.isError)
                finally:
                    proc.terminate()
                    try:
                        proc.wait(timeout=3)
                    except subprocess.TimeoutExpired:
                        proc.kill()
                        proc.wait()

    def test_ambiguous_session_is_not_selected(self):
        with patch.dict(os.environ, {}, clear=True), patch.object(server, "candidates", return_value=["/a", "/b"]):
            with self.assertRaisesRegex(ValueError, "explicit socket"):
                server.target("")

    def test_regular_file_is_rejected(self):
        with tempfile.NamedTemporaryFile() as file:
            with self.assertRaisesRegex(ValueError, "Unix socket"):
                server.rpc(file.name, "nvim_get_mode", [])


if __name__ == "__main__":
    unittest.main()
