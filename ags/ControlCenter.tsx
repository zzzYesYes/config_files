import app from "ags/gtk4/app"
import Astal from "gi://Astal?version=4.0"
import Gtk from "gi://Gtk?version=4.0"
import Gdk from "gi://Gdk?version=4.0"
import AstalWp from "gi://AstalWp"
import AstalBrightness from "gi://AstalBrightness"
import AstalMpris from "gi://AstalMpris"
import { For, With, createBinding } from "ags"

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

function VolumeSlider({ endpoint, icon }: { endpoint: AstalWp.Endpoint; icon: string }) {
  const volume = createBinding(endpoint, "volume")
  const muted = createBinding(endpoint, "mute")

  return (
    <box class="slider-row" spacing={8}>
      <button
        class="icon-btn"
        onClicked={() => endpoint.set_mute(!endpoint.mute)}
        tooltipText="Toggle mute"
      >
        <label label={muted((m) => (m ? ICON_MUTED : icon))} />
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

export default function ControlCenter() {
  const wp = AstalWp.get_default()
  const speaker = wp!.defaultSpeaker
  const mic = wp!.defaultMicrophone
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      name="control-center"
      namespace="control-center"
      application={app}
      visible={false}
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      layer={Astal.Layer.OVERLAY}
      marginTop={36}
      marginRight={6}
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
        <VolumeSlider endpoint={speaker} icon={ICON_OUT} />
        <VolumeSlider endpoint={mic} icon={ICON_MIC} />
        <BrightnessSlider />
        <MediaSection />
      </box>
    </window>
  )
}
