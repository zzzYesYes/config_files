import app from "ags/gtk4/app"
import Astal from "gi://Astal?version=4.0"
import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import AstalWp from "gi://AstalWp"
import AstalBrightness from "gi://AstalBrightness"
import AstalMpris from "gi://AstalMpris"
import AstalBluetooth from "gi://AstalBluetooth"
import AstalNetwork from "gi://AstalNetwork"
import { For, With, createBinding, createComputed } from "ags"
import { execAsync } from "ags/process"

const ICON_OUT = ""
const ICON_MIC = ""
const ICON_SUN = ""
const ICON_MUTED = ""
const ICON_PREV = ""
const ICON_PLAY = ""
const ICON_PAUSE = ""
const ICON_NEXT = ""
const ICON_MUSIC = ""
const BRIGHT_ICONS = ["", "", "", "", "", "", "", "", ""]

function VolumeSlider({ endpoint, icons, mutedIcon }: { endpoint: AstalWp.Endpoint; icons: string[]; mutedIcon: string }) {
  const volume = createBinding(endpoint, "volume")
  const muted = createBinding(endpoint, "mute")
  const icon = createComputed(() =>
    muted()
      ? mutedIcon
      : icons[Math.min(icons.length - 1, Math.floor(volume() * icons.length))],
  )

  return (
    <box class="slider-row" spacing={8}>
      <button
        class={muted((m) => (m ? "icon-btn muted" : "icon-btn"))}
        onClicked={() => endpoint.set_mute(!endpoint.mute)}
        tooltipText="Toggle mute"
      >
        <label label={icon} />
      </button>
      <slider
        class="vol-slider"
        hexpand
        min={0}
        max={1}
        widthRequest={240}
        onChangeValue={({ value }) => endpoint.set_volume(value)}
        value={volume}
      />
      <label class="pct" label={volume((v) => `${Math.round(v * 100)}%`)} />
    </box>
  )
}

function BrightnessSlider() {
  const brightness = AstalBrightness.get_default()
  const screen = createBinding(brightness.screen, "brightness")

  return (
    <box class="slider-row" spacing={8}>
      <label class="row-icon" label={screen((v) => BRIGHT_ICONS[Math.min(BRIGHT_ICONS.length - 1, Math.floor(v * BRIGHT_ICONS.length))])} />
      <slider
        class="vol-slider"
        hexpand
        min={0}
        max={1}
        widthRequest={240}
        onChangeValue={({ value }) => (brightness.screen.brightness = value)}
        value={screen}
      />
      <label class="pct" label={screen((v) => `${Math.round(v * 100)}%`)} />
    </box>
  )
}

function Player({ player }: { player: AstalMpris.Player }) {
  return (
    <box class="player" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
      <label
        class="player-title"
        maxWidthChars={28}
        ellipsize={3}
        label={createBinding(player, "title")}
      />
      <label
        class="player-artist"
        maxWidthChars={28}
        ellipsize={3}
        label={createBinding(player, "artist")}
      />
      <box halign={Gtk.Align.CENTER} spacing={8}>
        <button
          class="icon-btn"
          onClicked={() => player.previous()}
          visible={createBinding(player, "canGoPrevious")}
        >
          <label label={ICON_PREV} />
        </button>
        <button
          class="icon-btn"
          onClicked={() => player.play_pause()}
          visible={createBinding(player, "canControl")}
        >
          <box>
            <label
              label={ICON_PAUSE}
              visible={createBinding(player, "playbackStatus")(
                (s) => s === AstalMpris.PlaybackStatus.PLAYING,
              )}
            />
            <label
              label={ICON_PLAY}
              visible={createBinding(player, "playbackStatus")(
                (s) => s !== AstalMpris.PlaybackStatus.PLAYING,
              )}
            />
          </box>
        </button>
        <button
          class="icon-btn"
          onClicked={() => player.next()}
          visible={createBinding(player, "canGoNext")}
        >
          <label label={ICON_NEXT} />
        </button>
      </box>
    </box>
  )
}

function BluetoothSection() {
  const bt = AstalBluetooth.get_default()
  const powered = createBinding(bt, "isPowered")
  const devices = createBinding(bt, "devices")
  const adapter = createBinding(bt, "adapter")

  const status = createComputed(() => {
    if (!powered()) return "Off"
    const conn = devices().filter((d) => d.connected)
    return conn.length > 0 ? conn.map((d) => d.alias).join(", ") : "On"
  })

  const BT_ICON = ""

  return (
    <box class="slider-row bt-row" spacing={8}>
      <button
        class={powered((p) => (p ? "icon-btn bt-toggle" : "icon-btn bt-toggle off"))}
        onClicked={() => {
          const a = adapter()
          if (a) a.powered = !a.powered
        }}
        tooltipText="Toggle bluetooth"
      >
        <label label={BT_ICON} />
      </button>
      <label class="bt-status" hexpand xalign={0} label={status} />
      <button
        class="cc-btn"
        onClicked={() => execAsync("/home/zzz/.config/waybar/bt-menu.sh").catch(() => {})}
        tooltipText="Manage devices"
      >
        <label label="Devices" />
      </button>
    </box>
  )
}

function NetworkSection() {
  const network = AstalNetwork.get_default()
  const wifi = createBinding(network, "wifi")
  const wired = createBinding(network, "wired")
  const primary = createBinding(network, "primary")

  const onWired = createComputed(() => {
    const w = wired()
    return primary() === AstalNetwork.Primary.WIRED && !!w
  })

  const iconName = createComputed(() => {
    if (onWired()) return wired()?.iconName ?? "network-wired-symbolic"
    const w = wifi()
    if (!w || !w.enabled) return "network-wireless-disabled-symbolic"
    return w.iconName
  })

  const status = createComputed(() => {
    if (onWired()) return "Ethernet"
    const w = wifi()
    if (!w || !w.enabled) return "Off"
    return w.ssid || "Disconnected"
  })

  return (
    <box class="slider-row net-row" spacing={8}>
      <button
        class={wifi((w) => (w && w.enabled ? "icon-btn net-toggle" : "icon-btn net-toggle off"))}
        onClicked={() => {
          const w = wifi()
          if (w) w.enabled = !w.enabled
        }}
        tooltipText="Toggle wifi"
      >
        <image pixelSize={16} iconName={iconName} />
      </button>
      <label class="bt-status" hexpand xalign={0} label={status} />
      <button
        class="cc-btn"
        onClicked={() => {
          const w = wifi()
          if (w) w.scan()
          execAsync("/home/zzz/.config/waybar/net-menu.sh").catch(() => {})
        }}
        tooltipText="Available networks"
      >
        <label label="Networks" />
      </button>
    </box>
  )
}

function MediaSection() {
  const mpris = AstalMpris.get_default()
  const players = createBinding(mpris, "players")

  return (
    <box class="media" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
      <With value={players}>
        {(ps) =>
          ps.length > 0 ? (
            <Player player={ps[0]} />
          ) : (
            <label class="row-icon dim" label={`${ICON_MUSIC} Nothing playing`} />
          )
        }
      </With>
    </box>
  )
}

import GLib from "gi://GLib"
import { execAsync } from "ags/process"

const STATE_FILE = "/tmp/cc-visible"

function syncState(visible: boolean) {
  GLib.file_set_contents(STATE_FILE, visible ? "1" : "0")
  execAsync("pkill -RTMIN+8 waybar").catch(() => {})
}

export default function ControlCenter() {
  const wp = AstalWp.get_default()
  const speaker = wp!.defaultSpeaker
  const mic = wp!.defaultMicrophone
  const { TOP, RIGHT } = Astal.WindowAnchor

  syncState(false)

  return (
    <window
      $={(self) => {
        self.connect("notify::visible", () => syncState(self.visible))
      }}
      name="control-center"
      namespace="control-center"
      application={app}
      visible={false}
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      layer={Astal.Layer.OVERLAY}
      marginTop={2}
      marginRight={2}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <Gtk.EventControllerKey
        onKeyPressed={(_, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            app.toggle_window("control-center")
            return true
          }
          return false
        }}
      />
      <box class="control-center" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
        <label class="cc-title" label="Control Center" />
        <VolumeSlider endpoint={speaker} icons={["", "", ""]} mutedIcon={""} />
        <VolumeSlider endpoint={mic} icons={[""]} mutedIcon={""} />
        <BrightnessSlider />
        <BluetoothSection />
        <NetworkSection />
        <MediaSection />
      </box>
    </window>
  )
}
