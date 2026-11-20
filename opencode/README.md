# OpenCode configuration

## Files

- `cli.json`: terminal settings, symlinked from `~/.config/opencode/cli.json`.
- `opencode.jsonc`: permission rules and the existing Pilot plugin, also symlinked globally.
- `plugins/tab-toggle/`: a local TUI-only plugin for vertical session tabs.
- The provider-managed `~/.config/opencode/opencode.json` remains outside this repository.

## Shortcuts

With the default leader (`Ctrl+X`), release the leader before pressing the second key:

- Leader+S: open the session list (`session.list`).
- Leader+L: show or hide the left-hand session tabs (`zzz.tabs.toggle`).
- Leader+B: the built-in session sidebar toggle; this controls a different panel.
- Status no longer has Leader+S; it remains available in the command palette (`Ctrl+P`).

Restart the TUI once after installing the local plugin. Valid CLI settings changes then reload live.

The tab toggle changes `tabs.mode` between `on` and `off` and keeps `tabs.layout` vertical.
It preserves unrelated settings and writes through the canonical path without replacing the symlink.
Visibility is saved in the tracked `cli.json`, so toggling may leave this repository modified.
Explicit inline tab overrides in `OPENCODE_CLI_CONFIG_CONTENT` must be removed before toggling.

## Verification

Executed on 2026-11-20 with OpenCode 2.1.3:

- All eight Node unit tests passed, including mode transitions, legacy settings, invalid JSON,
  unrelated-setting preservation, file permissions, and symlink preservation.
- An isolated tmux TUI registered the command, accepted Leader+L in both directions, displayed
  success toasts, preserved the config symlink, and opened the session list with Leader+S.
- The TUI test used a temporary `XDG_CONFIG_HOME`; it did not toggle the user's live CLI config.

Reproduce from this repository's root:

```sh
rtk node --test opencode/plugins/tab-toggle/tabs.test.js
rtk python3 opencode/plugins/tab-toggle/tui.test.py
```

The integration test requires `rtk`, `tmux`, and `opencode` on `PATH`. Set `TMPDIR` to the approved
OpenCode temporary directory when running through the agent. Failure screenshots stay local and
must be reviewed and redacted before sharing. The test opens no model prompt.

Key outputs are `pass 8`, `fail 0`, `CLI_SYMLINK_PRESERVED true`, and
`LEADER_S session list visible`.

## References

- [CLI settings](https://opencode.ai/v2/docs/cli/config)
- [Keybindings](https://opencode.ai/v2/docs/cli/keybinds)
- [CLI plugin configuration](https://opencode.ai/v2/docs/cli/plugins)
- [TUI plugin API](https://opencode.ai/v2/docs/build/plugins/cli)
- [Permissions](https://opencode.ai/v2/docs/permissions)
