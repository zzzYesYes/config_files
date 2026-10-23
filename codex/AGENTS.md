<!-- rtk-instructions v2 -->
# RTK

Prefix every shell command with `rtk`: `rtk git status`, `rtk cargo test`,
`rtk npm run build`, `rtk ls src/`. Keep the prefix inside chains:
`rtk git add . && rtk git commit -m "msg"`. Commands RTK has no filter for
run as-is, so the prefix is always safe.

# Command output

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk bypass <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.

## About RTK

RTK (Rust Token Killer) is a CLI proxy that filters command output to save
tokens; behavior and exit code are unchanged.

- `rtk gain` / `rtk gain --history` — token savings, overall and per command.
- `rtk bypass <cmd>` — run a command unfiltered, still tracked.
- `RTK_DISABLED=1 <cmd>` — skip RTK for one command.
- `rtk discover` — find past commands RTK could have condensed.
<!-- /rtk-instructions -->

# Dotfiles convention

App configs live in `~/config_files` (a git repo) and are symlinked to
their expected locations. When installing or configuring a new app, put
its config in `~/config_files/<app>/`, symlink it back (e.g.
`ln -s ~/config_files/<app> ~/.config/<app>`), and commit the change.

Current links:
- `~/.config/tmux` -> `~/config_files/tmux`
- `~/.config/nvim` -> `~/config_files/nvim`
- `~/.config/btop` -> `~/config_files/btop`
- `~/.config/starship.toml` -> `~/config_files/starship/starship.toml`
- `~/.config/ghostty/config` -> `~/config_files/ghostty/config`
- `~/AGENTS.md` -> `~/config_files/codex/AGENTS.md`

# Global Markdown documentation

- Keep every Markdown line at or below 100 characters.
- Reflow prose, lists, and headings instead of relying on horizontal scrolling.
- Avoid Markdown tables when their rows would exceed the limit; use lists instead.
- Prefer short canonical reference URLs when an equivalent official URL exists.
- Give substantial concepts or knowledge areas their own focused Markdown documents.
- Cross-link focused documents from the project index or primary investigation document.
- Keep detailed references in the focused document they support.
- After changing Markdown, run this checker from the project root:
  `rtk python3 ~/config_files/codex/scripts/check-markdown-line-length.py .`

# Plan review

For substantial planning tasks:

1. Draft the plan without editing project files.
2. Spawn one read-only reviewer subagent with the current context.
3. Ask the reviewer to verify the plan against the repository and identify incorrect
   assumptions, missing dependencies, ordering problems, risks, and missing tests.
4. Wait for the review, then validate each finding before applying it.
5. Revise the plan using valid findings and explain any rejected findings.
6. Present the final plan with a brief summary of the resolved review findings.

This instruction explicitly authorizes one reviewer subagent for each substantial planning task.
