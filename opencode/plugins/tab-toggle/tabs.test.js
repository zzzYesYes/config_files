import assert from "node:assert/strict"
import { mkdtemp, readFile, readdir, rm, stat, symlink, lstat, writeFile } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"
import test from "node:test"
import { toggleTabs } from "./tabs.js"

async function fixture(t, config) {
  const directory = await mkdtemp(join(tmpdir(), "opencode-tabs-test-"))
  t.after(() => rm(directory, { recursive: true, force: true }))
  const path = join(directory, "cli.json")
  await writeFile(path, JSON.stringify(config), { mode: 0o600 })
  return { directory, path, read: async () => JSON.parse(await readFile(path, "utf8")) }
}

test("toggles off -> on -> off and preserves unrelated settings", async (t) => {
  const original = {
    theme: { name: "catppuccin", mode: "dark" },
    tabs: { mode: "off", layout: "vertical", scope: "global", indicators: "numbers" },
    keybinds: { "session.list": "<leader>s" },
    plugins: ["file:///example/plugin"],
  }
  const f = await fixture(t, original)
  assert.equal(await toggleTabs(f.path, false), "on")
  assert.deepEqual(await f.read(), { ...original, tabs: { ...original.tabs, mode: "on" } })
  // The saved mode, not a possibly stale renderer value, controls the next toggle.
  assert.equal(await toggleTabs(f.path, false), "off")
  assert.deepEqual(await f.read(), original)
  assert.equal((await stat(f.path)).mode & 0o777, 0o600)
  assert.deepEqual(await readdir(f.directory), ["cli.json"])
})

for (const enabled of [true, false]) {
  test(`auto mode uses the actual enabled state (${enabled})`, async (t) => {
    const f = await fixture(t, { tabs: { mode: "auto" } })
    assert.equal(await toggleTabs(f.path, enabled), enabled ? "off" : "on")
    assert.equal((await f.read()).tabs.layout, "vertical")
  })
}

test("missing tabs use the actual enabled state", async (t) => {
  const f = await fixture(t, { theme: { name: "catppuccin" } })
  assert.equal(await toggleTabs(f.path, true), "off")
  assert.deepEqual((await f.read()).theme, { name: "catppuccin" })
})

for (const enabled of [true, false]) {
  test(`supports legacy tabs.enabled (${enabled})`, async (t) => {
    const f = await fixture(t, { tabs: { enabled } })
    assert.equal(await toggleTabs(f.path, !enabled), enabled ? "off" : "on")
  })
}

test("updates the target without replacing its symlink", async (t) => {
  const f = await fixture(t, { tabs: { mode: "off" } })
  const link = join(f.directory, "cli-link.json")
  await symlink(f.path, link)
  assert.equal(await toggleTabs(link, false), "on")
  assert.equal((await lstat(link)).isSymbolicLink(), true)
  assert.equal((await f.read()).tabs.mode, "on")
})

test("invalid JSON fails without altering the file or leaving temporary files", async (t) => {
  const f = await fixture(t, {})
  await writeFile(f.path, "not JSON")
  await assert.rejects(toggleTabs(f.path, false), SyntaxError)
  assert.equal(await readFile(f.path, "utf8"), "not JSON")
  assert.deepEqual(await readdir(f.directory), ["cli.json"])
})
