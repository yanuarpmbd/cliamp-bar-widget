import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "bol.cliamp-bar"

  readonly property int configuredFps: Number(setting("fps", 20))
  readonly property bool showTrack: Boolean(setting("showTrack", true))
  readonly property int maxTitleLength: Number(setting("maxTitleLength", 24))
  readonly property bool adaptiveColors: Boolean(setting("adaptiveColors", true))

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  CliampService {
    id: cliamp
    fps: root.configuredFps
  }

  IpcHandler {
    target: "cliamp-bar"

    function toggle(): void { cliamp.togglePlayback() }
    function next(): void { cliamp.nextTrack() }
    function prev(): void { cliamp.prevTrack() }
    function nextVis(): void { cliamp.nextVisualizer() }
    function setVis(name: string): void { cliamp.setVisualizer(name) }
    function open(): void { cliamp.openCliampWindow() }
  }

  function truncate(str, maxLen) {
    var s = String(str || "").trim()
    if (s.length <= maxLen) return s
    return s.substring(0, maxLen - 1) + "…"
  }

  function buildTooltip() {
    if (!cliamp.cliampRunning) {
      return "cliamp is not running\nClick to launch"
    }
    var track = cliamp.trackTitle || "No track playing"
    var artist = cliamp.trackArtist ? (" - " + cliamp.trackArtist) : ""
    var state = cliamp.playbackState
    var vis = cliamp.activeVisualizer
    return track + artist + "\n[" + state.toUpperCase() + "] Visualizer: " + vis + "\nLeft-click: Play/Pause | Right-click: Next Vis | Scroll: Vol"
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    labelVisible: false
    hasVisualContent: cliamp.cliampRunning || cliamp.isPlaying
    tooltipText: root.buildTooltip()

    fixedWidth: root.vertical ? root.barSize : (contentRow.implicitWidth + scaledHorizontalMargin * 2)

    onPressed: function(b) {
      if (b === Qt.LeftButton) {
        if (!cliamp.cliampRunning) {
          cliamp.openCliampWindow()
        } else {
          cliamp.togglePlayback()
        }
      } else if (b === Qt.RightButton) {
        cliamp.nextVisualizer()
      } else if (b === Qt.MiddleButton) {
        cliamp.nextTrack()
      }
    }

    onWheelMoved: function(delta) {
      cliamp.adjustVolume(delta > 0 ? 2 : -2)
    }

    Row {
      id: contentRow
      anchors.centerIn: parent
      spacing: Style.space(6)

      // State Icon (Play, Pause, or Music Note)
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
          if (!cliamp.cliampRunning) return "󰝚"
          if (cliamp.playbackState === "playing") return "♫"
          if (cliamp.playbackState === "paused") return "󰏤"
          return "󰝚"
        }
        color: cliamp.isPlaying ? (root.adaptiveColors ? visRenderer.activeColor : Color.accent) : Color.muted
        font.family: button.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      // Track Title (Optional)
      Text {
        id: trackText
        anchors.verticalCenter: parent.verticalCenter
        visible: root.showTrack && cliamp.cliampRunning && cliamp.trackTitle !== "" && !root.vertical
        text: root.truncate(cliamp.trackTitle, root.maxTitleLength)
        color: button.foreground
        font.family: button.fontFamily
        font.pixelSize: Style.font.bodySmall
        renderType: Text.NativeRendering
      }

      // Adaptive Visualizer Canvas / Bars
      VisualizerRenderer {
        id: visRenderer
        anchors.verticalCenter: parent.verticalCenter
        bands: cliamp.bands
        visualizer: cliamp.activeVisualizer
        isPlaying: cliamp.isPlaying
        adaptiveColors: root.adaptiveColors
        defaultColor: Color.accent
        height: Math.max(14, Math.round(button.height * 0.6))
        width: root.vertical ? (button.width - 8) : 66
      }
    }
  }
}
