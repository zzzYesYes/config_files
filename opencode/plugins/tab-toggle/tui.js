import { Plugin } from "@opencode/plugin/tui"
import { homedir } from "node:os"
import { join } from "node:path"
import { toggleTabs } from "./tabs.js"

export default Plugin.define({
  id: "zzz.tabs",
  setup(context) {
    let pending = false
    const configPath = join(
      process.env.XDG_CONFIG_HOME || join(homedir(), ".config"),
      "opencode",
      "cli.json",
    )

    context.keymap.layer(() => ({
      mode: "global",
      commands: [
        {
          id: "zzz.tabs.toggle",
          title: "Toggle left session tabs",
          group: "Session",
          bind: "<leader>l",
          palette: true,
          run: async () => {
            if (pending) return
            pending = true
            try {
              const inline = JSON.parse(process.env.OPENCODE_CLI_CONFIG_CONTENT || "{}")
              if (inline.tabs && ["mode", "enabled", "layout"].some((key) => key in inline.tabs)) {
                throw new Error("Inline tab settings override cli.json; unset OPENCODE_CLI_CONFIG_CONTENT.")
              }
              const mode = await toggleTabs(configPath, context.ui.tabs.enabled())
              context.ui.toast.show({
                message: `Left session tabs ${mode === "on" ? "shown" : "hidden"}`,
                variant: "success",
              })
            } catch (error) {
              context.ui.toast.show({
                title: "Could not toggle session tabs",
                message: error instanceof Error ? error.message : String(error),
                variant: "error",
              })
            } finally {
              pending = false
            }
          },
        },
      ],
      bindings: ["zzz.tabs.toggle"],
    }))
  },
})
