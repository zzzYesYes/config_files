# Global model routing and data safety

## User policy

As of November 12, 2026, the user scopes the Confidential requirement to Ali-related data only.
Ali-related data means anything tied to Alibaba, Aliyun, Ant Group, DingTalk, Aone, Taobao,
Tmall, their internal systems, or data originating from them. Public availability does not
exempt Ali-related data. This preference supersedes the earlier all-data rule and the proposal
to use Qwen3.8-Max. Do not substitute another model automatically for Ali data, even if it
also has L4 scope.

- Ali-related data tasks: Token Switch **Confidential**,
  `mode-a4b81bd882fe493cbbdc1326291bd6ef`.
- Non-Ali work (including public-internet research, unrelated local files, and non-Ali data):
  no routing restriction; any available model may be used, including Token Switch **Ultra**,
  `mode-d98246c0ef8840b399161f798f5831b1`.
- If Confidential is unavailable for an Ali-data task, its effective route is unknown, or
  eligibility is unverified, stop before accessing that data and ask for an eligible
  Confidential session. Do not downgrade.
- These are user-selected preferences, not a benchmark-proven capability ranking. Catalog price
  multipliers do not establish performance, backend identity, or permission to handle data.

## Hard redline

Never expose Ali-related data to a model without explicit L4 data scope. For this user's
workflow, Ali-related data must go to Confidential, not merely to any L4-capable alternative.

Ali-related data includes real user, organization, customer, or system information from Ali
systems, regardless of whether it is classified L1, L2, L3, L4, or not yet classified.
Examples include Ali private source code, internal configuration contents, production
records, query results, schemas, operational logs, internal documents, screenshots,
identifiers, and information derived from these sources.

The rule applies to all model-visible surfaces: prompts, conversation history, attachments,
tool results, summaries, reasoning handoffs, and authorized subagent or reviewer contexts.
Do not pass Ali-related data to a non-L4 model to redact, classify, summarize, or decide
whether it is safe. Redaction, aggregation, pseudonyms, or removal of credentials do not
automatically make it unrestricted. Never expose credentials or secrets unnecessarily,
including to an L4-capable model.

A thread containing only non-Ali data or public web content is not restricted by this
redline and may be handled by any model. Do not transfer an Ali-data-bearing conversation
to Ultra or another non-L4 model. Request a Confidential session when Ali data is needed.

## Route verification and failure behavior

1. Before any operation reading Ali-related data, verify the effective session or delegated
   model is the Confidential managed route. A display name or local selection alone is
   insufficient proof.
2. Verify its explicit L4 scope and any sensitive-team/user-group eligibility requirements
   using trusted evidence already available or obtained within a verified Confidential session.
3. Use supported model controls if available. Editing instructions does not automatically switch
   the running session, reclassify existing context, or enforce network-level isolation.
4. If route verification or eligibility is missing for an Ali-data task, stop before reading or
   forwarding that data. Request an eligible Confidential session; do not use Ultra, Kimi, or
   an alternate L4 model.
5. Keep Ali-related data in Confidential throughout the task, including tool output and handoffs.
   A non-Ali task that later needs Ali-related data must establish Confidential before access.
6. Non-Ali tasks need no route verification and may run on any available model.

The policy is intentionally stricter than individual catalog scopes for Ali data. A model being
permitted to process L1-L3 does not permit it to receive this user's Ali-related data. A public
API with a similar model name does not inherit a managed Token Switch route's scope or
authorization.

## Primary evidence: local Token Switch catalog

Historical read-only observation on November 11, 2026, at 16:14:37 UTC+8:

- Source: `~/.token-switch/token-switch.db`, table `providers`, `app_type = 'codex'`.
- Description fields: `notes` and `meta.managedCatalog.description` matched on inspection.
- Catalog multiplier field: `meta.managedCatalog.multiplier`.
- Confidential: `0.5X`; described as a high-trust Qwen model for L4 data, restricted to
  sensitive teams and sensitive user groups. Its exact Chinese restriction is:
  `仅支持敏感团队、敏感人群处理L4机密数据`.
- Ultra: `1.6X`; described as an external model for complex tasks, explicitly prohibited from
  processing L4/P3 data: `不允许处理L4/P3数据`.
- Confidential had `is_current = 1` in the local catalog. This does not independently verify
  the effective running model or the user's sensitive-group eligibility.
- Recorded Codex catalog sync: November 11, 2026, at 16:12:47.365 UTC+8.

These are historical catalog observations, not a fresh verification for every future session.
Recheck changed routes, scopes, and eligibility before data access; fail closed if uncertain.

### Reproducible read-only catalog check

Run only within an already verified Confidential session, when verifying a route for an
Ali-data task. This query omits authentication fields:

```sh
rtk sqlite3 -readonly -header -column ~/.token-switch/token-switch.db "
SELECT name, id, is_current,
       json_extract(meta, '$.managedCatalog.multiplier') AS catalog_x,
       notes
FROM providers
WHERE app_type = 'codex'
  AND id IN ('mode-a4b81bd882fe493cbbdc1326291bd6ef',
             'mode-d98246c0ef8840b399161f798f5831b1');
SELECT key, value
FROM settings
WHERE key = 'managed_catalog_last_sync_ms_codex';
"
```

Expected matching fields from the historical observation: Confidential `catalog_x = 0.5`
with the restricted L4 description; Ultra `catalog_x = 1.6` with the L4/P3 prohibition.
Neither these multipliers nor `is_current` prove actual billing, capability, or
active-route identity.

The global entry point is [AGENTS.md](AGENTS.md), symlinked to `~/AGENTS.md`.
