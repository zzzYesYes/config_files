# Share Codex skills and CLI tools with OpenCode

## Scope and configuration

This migration is additive. Codex, its skills, installed CLI binaries, and their existing
credentials remain in place. No credentials, Codex hooks, or provider configuration were copied.

`opencode.jsonc` now registers this additional global source:

```jsonc
{
  "skills": ["~/.codex/skills"]
}
```

The existing schema, Pilot plugin, and permission rules were preserved.
The file remains symlinked from `~/.config/opencode/opencode.jsonc` into this repository.

OpenCode automatically discovers `~/.agents/skills`, which contains `a1` and 16 `dingtalk-*`
skills. It is not repeated in the explicit source array: explicit sources have higher precedence
than project-local skills, so duplicating the global source could change project overrides.

The visible Codex source currently contains `draw-io`. Its hidden `.system` directory is skipped,
so `imagegen`, `openai-docs`, `review-agent`, `skill-creator`, and `skill-installer` are not shared.
Those bundled skills contain Codex-specific tools or installation assumptions.

Future nonhidden skills installed under `~/.codex/skills` will also be shared automatically.
Review their tool and dependency compatibility before relying on them in OpenCode.

## CLI and authentication reuse

`a1`, `dws`, and `at-cli` already resolve from `~/.local/bin` in the OpenCode shell environment.
No executable migration or duplicate installation was necessary.

Observed versions on 2026-11-20:

- Codex: `0.167.1`.
- OpenCode: `2.1.3`.
- a1: `0.2.90`; the official registry reported stable `0.2.93`.
- DWS: `1.0.67`; its version check reported `1.0.68` available.
- Node: `v26.12.1`.
- draw.io Desktop: `32.6.1`.

No upgrades were performed. [CLI authentication](cli-auth.md) documents the fresh identity/token
checks and conditional login commands. Business actions and their resource permissions were not
exercised during migration.

## Verification

### Normal service discovery

Executed after reloading configuration:

```sh
rtk opencode reload
rtk opencode api get /api/skill
```

The reload returned `Configuration reloaded`. The skill response contained 20 entries: two
OpenCode built-ins, the 17 existing shared skills, and `draw-io`.

Selected `data[].id` and `data[].path` fields were:

- `a1`: `/Users/zzz/.agents/skills/a1/SKILL.md`.
- `dingtalk-shared`: `/Users/zzz/.agents/skills/dingtalk-shared/SKILL.md`.
- `draw-io`: `/Users/zzz/.codex/skills/draw-io/SKILL.md`.

None of the five hidden Codex system IDs was present.

### Fresh standalone skill loading

Executed from the repository root, with `TMPDIR` set to the approved OpenCode temporary directory:

```sh
rtk python3 opencode/scripts/verify-skill-sharing.py
```

The checker creates an isolated database and a temporary project whose Build agent permits only
skill loading. It sends one minimal model prompt requesting `a1`, `dingtalk-shared`, and `draw-io`.
It does not permit shell commands, business tools, file operations, or subagents.

Fresh result on 2026-11-20:

```text
RUN_EXIT 0
TEST_SESSION_IDS ["ses_e085f7b89ffezwJTeZ40Y2TeSw"]
OTHER_TOOL_CALLS []
FRESH_STANDALONE_SKILL_LOADING True
USER_DATABASE_UNCHANGED True
```

All three actual skill-tool calls had status `completed`. Their base directories matched the
three sources above, with the trailing `SKILL.md` removed. Full events remain local; review and
redact them before sharing.

### Standalone API discrepancy

The separate read-only command below returned an empty `data` array both before and after sharing:

```sh
rtk opencode api --standalone get /api/skill
```

Its location was `/Users/zzz`. Actual skill loading in a fresh standalone model session succeeded,
so this API-list result does not prove skill unavailability. The cause remains unverified; this
migration does not claim to fix the experimental API's registration behavior.

### draw.io export and lint dependencies

At `2026-11-20T06:21:41Z`, a scratch copy of the existing border-overlap fixture was exported to SVG
and PNG using the existing helper. No `--open`, `--delete-source`, or dependency installation ran.

From the scratch directory, the executed commands were:

```sh
rtk node ~/.codex/skills/draw-io/scripts/export-drawio.mjs border-overlap.drawio --format svg
rtk node ~/.codex/skills/draw-io/scripts/export-drawio.mjs border-overlap.drawio --format png
rtk node ~/.codex/skills/draw-io/scripts/check-drawio-svg-overlaps.mjs border-overlap.drawio.svg
```

Both exports completed with `[export-drawio] done`. SVG and PNG embedded source was verified.
The PNG was 956 by 300 pixels. The lint checker parsed two cells and one routed edge, and reported
one `edge-rect-border` issue: a 280-pixel top-border overlap. Exit 1 was expected for this
intentionally invalid fixture; it is not a clean-diagram result. Visual inspection confirmed the
same overlap, with legible text and arrowhead and no additional visible text overflow.

The scratch artifacts and exact commands are under the approved temporary base directory in
`draw-io-dependency-check.yBibrZ/`. Only scratch copies were written; originals were retained.

## Remaining dependency limits

- `python3` is installed, but bare `python` is absent. Some DWS examples prescribe `python`.
  Use `python3` for compatible scripts. Managed skill content was not modified, and no alias
  was installed.
- `aone-knowledge` and `aone-pipeline` are not installed in the shared sources. The a1 skill's
  domain-specific loading/fallback rules still apply; complete a1 workflow coverage is not claimed.
- Codex-specific R2C, Pilot, and a1 hooks were not ported. OpenCode keeps its existing Pilot plugin.
- Normal-service discovery and fresh standalone loading were tested. A new normal TUI model
  conversation was not created solely for verification, preserving the user's conversation store.

## Review findings resolved

One read-only reviewer checked the plan before configuration edits. Its findings led to retaining
normal `.agents` precedence, excluding hidden system skills, checking source paths and fresh actual
loading, documenting the missing Python command, and testing real diagram export/edge inspection.
The unexplained API discrepancy and untested business permissions remain explicitly qualified.

## References

- [OpenCode skills, sources, and precedence](https://opencode.ai/v2/docs/skills)
- [OpenCode configuration](https://opencode.ai/v2/docs/config)
- [OpenCode agents and permissions](https://opencode.ai/v2/docs/agents)
- [Configuration index](README.md)
- [CLI authentication](cli-auth.md)
