# Tab-toggle reload regression

## Observed failure

On 2026-11-20, OpenCode 2.1.3 accepted Leader+L and the plugin saved `tabs.mode: "on"`.
It displayed `Left session tabs shown`, but the left-hand panel did not render.

The earlier integration test checked only the saved mode and toast. Its passing result did not
establish that the panel appeared. That verification gap is now covered by a rendering assertion.

The corrected regression test failed before the fix with:

```text
BASELINE_RENDERED_TITLE_COUNT 1
PLUGIN_COMMAND_REGISTERED true
AssertionError: Left tab panel did not render
```

The test used an isolated database with one empty session titled `TAB_FIXTURE` and a temporary
`XDG_CONFIG_HOME`. No prompt was sent, and the user's database and live CLI config were untouched.

## Cause and primary evidence

The installed executable was `/opt/homebrew/Cellar/opencode/2.1.3/bin/opencode`.
Its embedded `vro` config-provider implementation subscribes to the parent of the config path:

```text
c=r?.path?vme(Shl.dirname(r.path),...)
```

This is an abbreviated excerpt from the installed binary, not pseudocode. It watches the directory
containing the symlink, rather than the directory containing its target. The plugin atomically
replaced the target file in a different directory, so it did not notify the CLI's directory watcher.

The relevant paths are:

- Watched config link: `~/.config/opencode/cli.json`.
- Canonical target: `~/config_files/opencode/cli.json`.

Read-only verification of the installed implementation:

```sh
rtk python3 - <<'PY'
from pathlib import Path
binary = Path('/opt/homebrew/Cellar/opencode/2.1.3/bin/opencode').read_bytes()
marker = b'c=r?.path?vme(Shl.dirname(r.path),'
print('WATCHES_CONFIG_PARENT', marker in binary)
PY
```

Expected matching output is `WATCHES_CONFIG_PARENT True` for this installed version.
This implementation detail is version-specific; it is not a promised plugin API.

## Fix

`plugins/tab-toggle/tabs.js` still writes the canonical target atomically. When the active config
path is a symlink, it then calls `lutimes` on that link to notify the watched config directory.
It does not replace the symlink or create a second config file.

The unit test verifies the link remains intact and its timestamp changes. The integration test
checks the actual rendered fixture title count before and after the toggle.

## Fresh verification

Executed after the fix on 2026-11-20 with OpenCode 2.1.3:

```text
BASELINE_RENDERED_TITLE_COUNT 1
PLUGIN_COMMAND_REGISTERED true
LEADER_L tabs.mode=on; rendered title count=2
LEADER_L tabs.mode=off; rendered title count=1
CLI_SYMLINK_PRESERVED true
LEADER_S session list visible
USER_CONFIG_AND_DATABASE_UNCHANGED true (isolated test fixtures)
```

Reproduce from the repository root with `TMPDIR` set to the approved OpenCode temporary directory:

```sh
rtk node --test opencode/plugins/tab-toggle/tabs.test.js
rtk python3 opencode/plugins/tab-toggle/tui.test.py
```

The live existing TUI was not restarted by the agent. Restart it once to load the corrected plugin,
then use Ctrl+X, release, and L. Subsequent toggles should reload without restarting.

## References

- [CLI settings and live reload](https://opencode.ai/v2/docs/cli/config)
- [TUI plugin API](https://opencode.ai/v2/docs/build/plugins/cli)
- [OpenCode troubleshooting](https://opencode.ai/v2/docs/troubleshooting)
- [Configuration index](README.md)
