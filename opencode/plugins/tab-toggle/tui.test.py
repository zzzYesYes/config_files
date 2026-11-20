"""Check rendered tab visibility with an isolated database and symlinked CLI config."""

import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import time
import uuid

ROOT = Path(tempfile.mkdtemp(prefix="opencode-tab-toggle-tui-"))
CONFIG = ROOT / "opencode" / "cli.json"
CONFIG.parent.mkdir()
TARGET = ROOT / "tracked-cli.json"
settings = json.loads(Path(__file__).resolve().parents[2].joinpath("cli.json").read_text())
settings["tabs"]["mode"] = "off"
TARGET.write_text(json.dumps(settings, indent=2))
CONFIG.symlink_to(TARGET)
DATABASE = ROOT / "test.db"
TITLE = "TAB_FIXTURE"
SOCKET = "opencode-tabs-" + uuid.uuid4().hex[:10]
PREFIX = ["rtk", "tmux", "-L", SOCKET]


def tmux(*args, check=True):
    return subprocess.run(
        PREFIX + list(args), capture_output=True, text=True, check=check,
    ).stdout


def screen():
    return tmux("capture-pane", "-p", "-t", "test:0.0")


def wait_for(predicate, description, timeout=25):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        value = predicate()
        if value:
            return value
        time.sleep(0.15)
    # Only synthetic fixture data is displayed; still review screenshots before sharing.
    (ROOT / "last-screen.txt").write_text(screen())
    raise AssertionError(f"{description}; local screenshot: {ROOT}")


def mode():
    return json.loads(CONFIG.read_text())["tabs"]["mode"]


try:
    env = {**os.environ, "XDG_CONFIG_HOME": str(ROOT), "OPENCODE_DB": str(DATABASE)}
    env.pop("OPENCODE_CLI_CONFIG_CONTENT", None)
    fixture = subprocess.run(
        ["rtk", "opencode", "api", "--standalone", "post", "/api/session",
         "--data", json.dumps({"title": TITLE})],
        cwd=ROOT, env=env, capture_output=True, text=True, check=True,
    )
    session_id = json.loads(fixture.stdout)["data"]["id"]
    command = (
        "rtk env XDG_CONFIG_HOME=" + shlex.quote(str(ROOT)) +
        " OPENCODE_DB=" + shlex.quote(str(DATABASE)) +
        " OPENCODE_CLI_CONFIG_CONTENT= rtk opencode --standalone --session " +
        shlex.quote(session_id) + " " + shlex.quote(str(ROOT))
    )
    tmux("-f", "/dev/null", "new-session", "-d", "-s", "test", "-x", "160", "-y", "48", command)
    wait_for(lambda: TITLE in screen(), "Fixture session startup")
    baseline = screen().count(TITLE)
    print(f"BASELINE_RENDERED_TITLE_COUNT {baseline}")
    tmux("send-keys", "-t", "test:0.0", "C-p")
    tmux("send-keys", "-t", "test:0.0", "-l", "Toggle left session tabs")
    wait_for(lambda: screen().count("Toggle left session tabs") >= 2, "Command registration")
    print("PLUGIN_COMMAND_REGISTERED true")
    tmux("send-keys", "-t", "test:0.0", "Escape")
    for next_mode in ["on", "off"]:
        tmux("send-keys", "-t", "test:0.0", "C-x", "l")
        wait_for(lambda: mode() == next_mode, f"Leader+L did not set tabs.mode={next_mode}")
        label = "shown" if next_mode == "on" else "hidden"
        wait_for(lambda: f"Left session tabs {label}" in screen(), "Success toast missing")
        if next_mode == "on":
            wait_for(lambda: screen().count(TITLE) > baseline, "Left tab panel did not render")
        else:
            wait_for(lambda: screen().count(TITLE) == baseline, "Left tab panel did not disappear")
        print(f"LEADER_L tabs.mode={next_mode}; rendered title count={screen().count(TITLE)}")
    assert CONFIG.is_symlink(), "Toggle replaced the CLI config symlink"
    print("CLI_SYMLINK_PRESERVED true")
    tmux("send-keys", "-t", "test:0.0", "C-x", "s")
    wait_for(
        lambda: "Sessions" in screen() or "Search sessions" in screen(),
        "Leader+S did not open session list",
    )
    print("LEADER_S session list visible")
    print("USER_CONFIG_AND_DATABASE_UNCHANGED true (isolated test fixtures)")
finally:
    tmux("send-keys", "-t", "test:0.0", "Escape", "C-c", check=False)
    tmux("kill-server", check=False)
