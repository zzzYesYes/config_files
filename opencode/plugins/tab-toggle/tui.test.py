"""Exercise the real TUI in an isolated tmux server and temporary CLI config."""

import json
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
TARGET.write_text(Path(__file__).resolve().parents[2].joinpath("cli.json").read_text())
CONFIG.symlink_to(TARGET)
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
    # Keep failure evidence local; review and redact it before sharing.
    (ROOT / "last-screen.txt").write_text(screen())
    raise AssertionError(f"{description}; local screenshot: {ROOT}")


def mode():
    return json.loads(CONFIG.read_text())["tabs"]["mode"]


try:
    initial_mode = mode()
    command = (
        "rtk env XDG_CONFIG_HOME=" + shlex.quote(str(ROOT)) +
        " OPENCODE_CLI_CONFIG_CONTENT= rtk opencode --standalone"
    )
    tmux("-f", "/dev/null", "new-session", "-d", "-s", "test", "-x", "160", "-y", "48", command)
    wait_for(lambda: "ctrl+p commands" in screen() or "Ask anything" in screen(), "TUI startup")
    tmux("send-keys", "-t", "test:0.0", "C-p")
    tmux("send-keys", "-t", "test:0.0", "-l", "Toggle left session tabs")
    wait_for(lambda: screen().count("Toggle left session tabs") >= 2, "Command registration")
    print("PLUGIN_COMMAND_REGISTERED true")
    tmux("send-keys", "-t", "test:0.0", "Escape")
    for next_mode in (["off", "on"] if initial_mode == "on" else ["on", "off"]):
        tmux("send-keys", "-t", "test:0.0", "C-x", "l")
        wait_for(lambda: mode() == next_mode, f"Leader+L did not set tabs.mode={next_mode}")
        label = "shown" if next_mode == "on" else "hidden"
        wait_for(lambda: f"Left session tabs {label}" in screen(), "Success toast missing")
        print(f"LEADER_L tabs.mode={next_mode}; success toast visible")
    assert CONFIG.is_symlink(), "Toggle replaced the CLI config symlink"
    print("CLI_SYMLINK_PRESERVED true")
    tmux("send-keys", "-t", "test:0.0", "C-x", "s")
    wait_for(
        lambda: "Sessions" in screen() or "Search sessions" in screen(),
        "Leader+S did not open session list",
    )
    print("LEADER_S session list visible")
    print("USER_CONFIG_UNCHANGED true (isolated XDG_CONFIG_HOME)")
finally:
    tmux("send-keys", "-t", "test:0.0", "Escape", "C-c", check=False)
    tmux("kill-server", check=False)
