import { lstat, lutimes, readFile, realpath, rename, stat, unlink, writeFile } from "node:fs/promises"
import { randomUUID } from "node:crypto"

// Write through the canonical path so atomic replacement never removes a dotfile symlink.
export async function toggleTabs(configPath, currentlyEnabled) {
  const target = await realpath(configPath)
  const config = JSON.parse(await readFile(target, "utf8"))
  const tabs = config.tabs ?? {}
  const mode = tabs.mode ?? (tabs.enabled === undefined ? "auto" : tabs.enabled ? "on" : "off")
  const enabled = mode === "auto" ? currentlyEnabled : mode === "on"
  const nextMode = enabled ? "off" : "on"
  config.tabs = { ...tabs, mode: nextMode, layout: "vertical" }

  const temporary = `${target}.${randomUUID()}.tmp`
  try {
    const metadata = await stat(target)
    await writeFile(temporary, `${JSON.stringify(config, null, 2)}\n`, {
      flag: "wx",
      mode: metadata.mode & 0o777,
    })
    await rename(temporary, target)
    // OpenCode 2.1.3 watches the config path's parent, not a symlink target's parent.
    // Notify that watcher without replacing the link or creating another config file.
    if ((await lstat(configPath)).isSymbolicLink()) {
      const now = new Date()
      await lutimes(configPath, now, now)
    }
  } finally {
    await unlink(temporary).catch((error) => {
      if (error.code !== "ENOENT") throw error
    })
  }
  return nextMode
}
