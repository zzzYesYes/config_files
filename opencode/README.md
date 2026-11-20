# OpenCode configuration

## Files

- `cli.json`: terminal settings, symlinked from `~/.config/opencode/cli.json`.
- `opencode.jsonc`: skill sources, permission rules, and the Pilot plugin; symlinked globally.
- `plugins/tab-toggle/`: a local TUI-only plugin for vertical session tabs.
- The provider-managed `~/.config/opencode/opencode.json` remains outside this repository.

## Shared skills and CLI tools

[Skill sharing](skill-sharing.md) documents the additive Codex migration, precedence decisions,
fresh standalone verification, and diagram export checks. Existing `a1` and DWS skills are shared
through `~/.agents/skills`; `draw-io` is shared from the additional `~/.codex/skills` source.

[CLI authentication](cli-auth.md) records the successful existing login checks. CLI binaries and
credentials are reused, not copied into OpenCode configuration. Codex remains intact.

## Shortcuts

With the default leader (`Ctrl+X`), release the leader before pressing the second key:

- Leader+S: open the session list (`session.list`).
- Leader+L: show or hide the left-hand session tabs (`zzz.tabs.toggle`).
- Leader+B: the built-in session sidebar toggle; this controls a different panel.
- Status no longer has Leader+S; it remains available in the command palette (`Ctrl+P`).

Restart the TUI once after installing the local plugin. Valid CLI settings changes then reload live.

The tab toggle changes `tabs.mode` between `on` and `off` and keeps `tabs.layout` vertical.
It preserves unrelated settings and writes through the canonical path without replacing the symlink.
It also updates the symlink's timestamps so OpenCode's config-directory watcher reloads
its settings.
See [the reload investigation](tab-toggle-reload.md) for the regression and its verification.
Visibility is saved in the tracked `cli.json`, so toggling may leave this repository modified.
Explicit inline tab overrides in `OPENCODE_CLI_CONFIG_CONTENT` must be removed before toggling.

## Verification

Executed on 2026-11-20 with OpenCode 2.1.3:

- All eight Node unit tests passed, including mode transitions, legacy settings, invalid JSON,
  unrelated-setting preservation, file permissions, symlink preservation, and reload notification.
- The corrected TUI test checks the rendered panel, not just config changes or success toasts.
  The synthetic session title count changed from 1 to 2 when shown, then returned to 1 when hidden.
- Leader+S still opened the session list, and the config symlink remained intact.
- The test used a temporary `XDG_CONFIG_HOME` and an isolated database containing one empty fixture
  session. It did not toggle the user's live config, modify their database, or send a model prompt.

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
