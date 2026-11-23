import app from "ags/gtk4/app"
import style from "./style.css"
import ControlCenter from "./ControlCenter"

app.start({
  css: style,
  gtkTheme: "Adwaita",
  main() {
    ControlCenter()
  },
})
