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

# Model routing and data-safety redline

- The Confidential/L4 restrictions in this section apply only to **Ali-related data**:
  anything tied to Alibaba, Aliyun, Ant Group, DingTalk, Aone, Taobao, Tmall, their
  internal systems, or data originating from them. Public availability does not exempt
  Ali-related data.
- For tasks involving Ali-related data, use Token Switch **Confidential**:
  `mode-a4b81bd882fe493cbbdc1326291bd6ef`. This is the user's designated best
  data-processing model for Ali data; do not substitute another model.
- Before accessing Ali-related data, verify the active managed route is Confidential, has
  explicit L4 scope, and satisfies the catalog's sensitive-team/user-group restrictions.
  If this cannot be verified or the route is unavailable, stop before data access and
  request an eligible Confidential session.
- **Redline: never expose Ali-related data to any model without explicit L4 data scope.**
  Apply this even to L1-L3 or unclassified Ali data. Ali-related data includes real user,
  organization, customer, or system data from Ali systems: files, source code, records,
  logs, documents, screenshots, and tool output.
- The boundary for Ali-related data covers prompts, conversation history, attachments,
  tool results, summaries, derived information, and authorized subagent/reviewer contexts.
  Redaction alone is not clearance.
- Do not switch an Ali-data-bearing thread to Ultra or another non-L4 model. If a no-data
  task later needs Ali-related data, establish an eligible Confidential route first.
- Non-Ali work has no routing restriction: any available model may be used, including
  public-internet research, unrelated local files, and non-Ali data processing.
- These instructions do not themselves switch the running model. For Ali-related data,
  verify the effective route; do not infer it from a model name, price, Token Switch
  selection alone, or a successful API call.
- Read the [model routing policy](/Users/zzz/config_files/agents/model-routing.md) for scope,
  current catalog evidence, verification commands, and fail-closed behavior.

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
- `~/AGENTS.md` -> `~/config_files/agents/AGENTS.md`

# Global Markdown documentation

- Keep every Markdown line at or below 100 characters.
- Reflow prose, lists, and headings instead of relying on horizontal scrolling.
- Avoid Markdown tables when their rows would exceed the limit; use lists instead.
- Prefer short canonical reference URLs when an equivalent official URL exists.
- When referencing external documentation or portals, include a clickable source link
  in both replies and written documentation.
- Give substantial concepts or knowledge areas their own focused Markdown documents.
- Cross-link focused documents from the project index or primary investigation document.
- Keep detailed references in the focused document they support.
- After changing Markdown, run this checker from the project root:
  `rtk python3 ~/config_files/agents/scripts/check-markdown-line-length.py .`

# Investigation and operational evidence

- Support every investigation or operational conclusion with primary evidence in
  replies and written documentation.
- Include reproducible verification steps: sanitized commands or API requests,
  relevant inputs/environment, and matching key outputs or response fields.
- Include source links, timestamps, and resource/request IDs where relevant.
- Separate observed facts from inferences; label conclusions without sufficient evidence
  as unverified.
- Distinguish historical evidence from fresh reproductions, and executed steps from
  proposed commands.
- Prefer read-only reproduction steps; do not repeat mutations solely to obtain proof.
- Redact credentials, tokens, secrets, and presigned URLs; clearly label excerpts and omissions.

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
