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
  readonly property bool autoHide: Boolean(setting("autoHide", true))
  readonly property int initialDisplayMode: Number(setting("displayMode", 1))

  // 1: Playback + Visualizer, 2: Visualizer only, 3: Playback only
  property int displayMode: initialDisplayMode

  visible: autoHide ? cliamp.cliampRunning : true
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0
  width: implicitWidth
  height: implicitHeight

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
    function setMode(mode: int): void { root.displayMode = Math.max(1, Math.min(3, mode)) }
    function cycleMode(): void { root.displayMode = (root.displayMode % 3) + 1 }
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
    var modeNames = { 1: "Playback + Visualizer", 2: "Visualizer Only", 3: "Playback Only" }
    var modeName = modeNames[root.displayMode] || "Playback + Visualizer"
    return track + artist + "\n[" + state.toUpperCase() + "] Mode: " + modeName + " | Vis: " + vis + "\nLeft-click: Play/Pause | Right-click: Next Vis | Scroll: Switch Display Mode"
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    labelVisible: false
    visible: root.visible
    hasVisualContent: root.visible
    keepSpace: false
    tooltipText: root.buildTooltip()

    fixedWidth: root.visible ? (root.vertical ? root.barSize : (contentRow.implicitWidth + scaledHorizontalMargin * 2)) : 0
    fixedHeight: root.visible ? (root.vertical ? (contentRow.implicitHeight + scaledVerticalPadding * 2) : root.barSize) : 0

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
      if (delta > 0) {
        // Scroll Up: 1 -> 2 -> 3 -> 1
        root.displayMode = (root.displayMode % 3) + 1
      } else if (delta < 0) {
        // Scroll Down: 1 -> 3 -> 2 -> 1
        root.displayMode = (root.displayMode === 1) ? 3 : (root.displayMode - 1)
      }
    }

    Row {
      id: contentRow
      anchors.centerIn: parent
      spacing: Style.space(6)
      visible: root.visible

      // State Icon (Play, Pause, or Music Note) - Visible in Mode 1 & 3
      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.displayMode === 1 || root.displayMode === 3
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

      // Track Title (Optional) - Visible in Mode 1 & 3
      Text {
        id: trackText
        anchors.verticalCenter: parent.verticalCenter
        visible: (root.displayMode === 1 || root.displayMode === 3) && root.showTrack && cliamp.cliampRunning && cliamp.trackTitle !== "" && !root.vertical
        text: root.truncate(cliamp.trackTitle, root.maxTitleLength)
        color: button.foreground
        font.family: button.fontFamily
        font.pixelSize: Style.font.bodySmall
        renderType: Text.NativeRendering
      }

      // Adaptive Visualizer Canvas / Bars - Visible in Mode 1 & 2
      VisualizerRenderer {
        id: visRenderer
        anchors.verticalCenter: parent.verticalCenter
        visible: root.displayMode === 1 || root.displayMode === 2
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
