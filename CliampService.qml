import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property int fps: 20
  property bool cliampRunning: false
  property string playbackState: "stopped" // "playing", "paused", "stopped"
  property string trackTitle: ""
  property string trackArtist: ""
  property string activeVisualizer: "Bars"
  property real trackDuration: 0
  property real trackPosition: 0
  property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  signal playbackUpdated()

  readonly property bool isPlaying: cliampRunning && playbackState === "playing"

  function togglePlayback() {
    Quickshell.execDetached(["cliamp", "toggle"])
  }

  function nextTrack() {
    Quickshell.execDetached(["cliamp", "next"])
  }

  function prevTrack() {
    Quickshell.execDetached(["cliamp", "prev"])
  }

  function nextVisualizer() {
    Quickshell.execDetached(["cliamp", "vis", "next"])
  }

  function setVisualizer(name) {
    Quickshell.execDetached(["cliamp", "vis", name])
  }

  function adjustVolume(delta) {
    var val = (delta > 0 ? "+" : "") + String(delta)
    Quickshell.execDetached(["cliamp", "volume", val])
  }

  function openCliampWindow() {
    // Focus existing cliamp foot terminal window or launch a new one
    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch focuswindow org.omarchy.cliamp || foot --app-id=org.omarchy.cliamp -e cliamp"])
  }

  function resetBands() {
    bands = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  }

  function handleStateLine(line) {
    var raw = String(line || "").trim()
    if (!raw || raw[0] !== "{") return
    try {
      var msg = JSON.parse(raw)
      var d = msg.data || msg
      if (d) {
        root.cliampRunning = true
        if (d.state) root.playbackState = String(d.state).toLowerCase()
        if (d.visualizer) root.activeVisualizer = d.visualizer
        if (d.track) {
          root.trackTitle = d.track.title || ""
          root.trackArtist = d.track.artist || ""
          root.trackDuration = d.track.duration_secs || d.duration || 0
        }
        if (d.position !== undefined) {
          root.trackPosition = d.position
        }
        root.syncVisStream()
        root.playbackUpdated()
      }
    } catch (e) {}
  }

  function handleVisLine(line) {
    var raw = String(line || "").trim()
    if (!raw || raw[0] !== "{") return
    try {
      var msg = JSON.parse(raw)
      if (msg && msg.bands && msg.bands.length > 0) {
        root.bands = msg.bands
        if (msg.visualizer && msg.visualizer !== root.activeVisualizer) {
          root.activeVisualizer = msg.visualizer
        }
      }
    } catch (e) {}
  }

  function syncVisStream() {
    if (root.isPlaying) {
      if (!visProcess.running) {
        visProcess.running = true
      }
    } else {
      if (visProcess.running) {
        visProcess.running = false
      }
      resetBands()
    }
  }

  onIsPlayingChanged: syncVisStream()

  // Process streaming real-time playback state events
  Process {
    id: stateProcess
    command: ["cliamp", "remote", "events", "runtime.state"]
    running: false
    stdout: SplitParser {
      onRead: function(line) {
        root.handleStateLine(line)
      }
    }
    onExited: function(code) {
      root.cliampRunning = false
      root.playbackState = "stopped"
      visProcess.running = false
      root.resetBands()
    }
  }

  // Process streaming FFT spectrum bands
  Process {
    id: visProcess
    command: ["cliamp", "visstream", "--fps", String(Math.max(10, Math.min(60, root.fps)))]
    running: false
    stdout: SplitParser {
      onRead: function(line) {
        root.handleVisLine(line)
      }
    }
    onExited: function(code) {
      if (root.isPlaying) {
        restartVisTimer.restart()
      }
    }
  }

  Timer {
    id: restartVisTimer
    interval: 500
    repeat: false
    onTriggered: {
      if (root.isPlaying && !visProcess.running) {
        visProcess.running = true
      }
    }
  }

  // Check if cliamp process is running
  Process {
    id: pingProcess
    command: ["pgrep", "-x", "cliamp"]
    stdout: StdioCollector { waitForEnd: true }
    onExited: function(code) {
      if (code === 0) {
        root.cliampRunning = true
        if (!stateProcess.running) {
          stateProcess.running = true
        }
      } else {
        root.cliampRunning = false
        root.playbackState = "stopped"
        if (stateProcess.running) stateProcess.running = false
        if (visProcess.running) visProcess.running = false
        root.resetBands()
      }
    }
  }

  // Periodic heartbeat to ensure connectivity
  Timer {
    id: heartbeatTimer
    interval: root.cliampRunning ? 3000 : 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
      if (!pingProcess.running) {
        pingProcess.running = true
      }
    }
  }

  Component.onCompleted: {
    pingProcess.running = true
  }
}
