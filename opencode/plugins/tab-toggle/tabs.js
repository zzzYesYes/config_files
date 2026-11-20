import { readFile, realpath, rename, stat, unlink, writeFile } from "node:fs/promises"
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
  } finally {
    await unlink(temporary).catch((error) => {
      if (error.code !== "ENOENT") throw error
    })
  }
  return nextMode
}
