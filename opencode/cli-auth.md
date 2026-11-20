# CLI authentication shared by Codex and OpenCode

## Existing login state verified

Fresh checks on 2026-11-20 succeeded in the OpenCode shell environment:

```sh
rtk at-cli exec skill 'a1' -- a1 auth whoami --format json --no-update-check
rtk dws auth status --format json
```

The a1 identity response reported `source: "ncs"` and a populated account, name, email, and employee
ID. DWS reported:

```json
{
  "success": true,
  "authenticated": true,
  "token_valid": true,
  "refresh_token_valid": true
}
```

The a1 employee ID and DWS user ID matched. Personal identity fields and credential data are omitted
from this document. Login readiness is verified, but per-resource business permissions are not.

Both CLIs were already authenticated, so no explicit login, logout, auth export, or auth import was
necessary. DWS status checks can refresh an existing token; they do not change the selected profile.

## Credential boundaries

- Both applications invoke the same local CLI binaries, which use their existing local auth state.
- Authentication is not stored in the OpenCode skill instructions or `opencode.jsonc`.
- No tokens, refresh tokens, provider credentials, or authentication archives were copied
  or committed.
- OpenCode model-provider authentication is separate and remains provider-managed.
- A successful identity/status check does not authorize repository pushes, messages, approvals,
  releases, or other business writes. Follow each skill's resource and confirmation rules.

## Login only when required

The following are proposed recovery commands, not operations executed during this migration.
Verify the relevant command's current leaf Help/Schema before recovery if parameters have changed.

For a1, the default flow validates NCS. In a noninteractive environment, NCS failure stops rather
than automatically opening a BUC browser flow:

```sh
rtk at-cli exec skill 'a1' -- a1 auth login
rtk at-cli exec skill 'a1' -- a1 auth whoami --format json --no-update-check
```

Explicit BUC login or AuthX approval must be completed by the account owner. The agent must not
open, click, or approve an AuthX link on their behalf. Never pass literal tokens in shell commands.

For ordinary local DWS browser login:

```sh
rtk dws auth login --recommend --format json
rtk dws auth status --format json
```

Use the documented `--device` flow when a browser cannot be opened. International/overseas login
requires `--intl`; do not apply it to the existing domestic profile without an explicit request.
Do not reset credentials or switch organizations merely to test migration.

## References

- [Local a1 authentication rules](../../.agents/skills/a1/references/auth-commands.md)
- [DWS auth rules](../../.agents/skills/dingtalk-shared/references/global-reference.md)
- [Skill sharing and verification](skill-sharing.md)
- [OpenCode skill discovery](https://opencode.ai/v2/docs/skills)
