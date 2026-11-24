"""Verify standalone skill loading in an isolated database with skill-only permissions."""

import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(tempfile.mkdtemp(prefix="opencode-skill-sharing-"))
config_dir = ROOT / ".opencode"
config_dir.mkdir()
(config_dir / "opencode.jsonc").write_text(json.dumps({
    "$schema": "https://opencode.ai/config.json",
    "agents": {
        "build": {
            "mode": "primary",
            "description": "Load selected skills only; no shell, files, network, or subagents.",
            "steps": 5,
            "permissions": [
                {"action": "*", "resource": "*", "effect": "deny"},
                {"action": "skill", "resource": "*", "effect": "allow"},
            ],
        },
    },
}, indent=2))
env = {**os.environ, "OPENCODE_DB": str(ROOT / "test.db")}
prompt = (
    "This is an installation check, not a business task. "
    "Use the skill tool to load each of these exact IDs: a1, dingtalk-shared, draw-io. "
    "Do not use any other tool, do not run shell commands, and do not read or modify other files. "
    "After loading the three skill bodies, stop and reply with the three IDs successfully loaded."
)
result = subprocess.run(
    ["rtk", "opencode", "run", "--standalone", "--format", "json",
     "--title", "Skill sharing verification", prompt],
    cwd=ROOT, env=env, capture_output=True, text=True, timeout=150,
)
# Full events stay local. Review and redact them before sharing.
(ROOT / "events.jsonl").write_text(result.stdout)
(ROOT / "stderr.txt").write_text(result.stderr)
print("CHECK_ROOT", ROOT)
print("RUN_EXIT", result.returncode)
loaded = {}
other_tools = []
sessions = set()
for line in result.stdout.splitlines():
    try:
        event = json.loads(line)
    except ValueError:
        continue
    if event.get("sessionID"):
        sessions.add(event["sessionID"])
    part = event.get("part", {})
    tool = part.get("tool")
    if not tool:
        continue
    state = part.get("state", {})
    if tool == "skill":
        skill_id = state.get("input", {}).get("id")
        match = re.search(r"Base directory for this skill:\s*([^\n]+)", state.get("output", ""))
        loaded[skill_id] = {
            "status": state.get("status"),
            "base_directory": match.group(1) if match else None,
        }
    else:
        other_tools.append({"tool": tool, "status": state.get("status")})
print("TEST_SESSION_IDS", json.dumps(sorted(sessions)))
print("SKILL_TOOL_RESULTS", json.dumps(loaded))
print("OTHER_TOOL_CALLS", json.dumps(other_tools))
expected = {
    "a1": Path.home() / ".agents/skills/a1",
    "dingtalk-shared": Path.home() / ".agents/skills/dingtalk-shared",
    "draw-io": Path.home() / ".codex/skills/draw-io",
}
assert result.returncode == 0, "OpenCode run failed; inspect and redact the local logs"
assert set(loaded) == set(expected), "Not all expected skills were actually invoked"
for skill_id, directory in expected.items():
    item = loaded[skill_id]
    assert item["status"] == "completed", f"Skill load failed: {skill_id}"
    assert item["base_directory"] == str(directory), f"Wrong skill source: {skill_id}"
assert not other_tools, "The verifier attempted another tool"
print("FRESH_STANDALONE_SKILL_LOADING", True)
print("USER_DATABASE_UNCHANGED", True)
