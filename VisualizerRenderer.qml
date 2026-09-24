import QtQuick
import qs.Commons

Item {
  id: root

  property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  property string visualizer: "Bars"
  property bool isPlaying: false
  property bool adaptiveColors: true
  property color defaultColor: Color.accent

  implicitWidth: 70
  implicitHeight: 20

  // Peak hold levels for ClassicPeak & BarsDot
  property var peakLevels: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  // Categorize the 31 visualizers into renderer types
  readonly property string category: {
    var v = visualizer.toLowerCase()
    if (v === "bars" || v === "columns") return "bars"
    if (v === "barsoutline") return "outline"
    if (v === "classicpeak" || v === "barsdot") return "peak"
    if (v === "classicled" || v === "bricks" || v === "mosaic" || v === "retro") return "led"
    if (v === "wave" || v === "scope" || v === "heartbeat" || v === "terrain") return "wave"
    if (v === "binary" || v === "matrix") return "digital"
    if (v === "mirror" || v === "stereo" || v === "butterfly") return "mirror"
    if (v === "rain" || v === "sakura" || v === "firefly" || v === "bubbles" ||
        v === "firework" || v === "scatter" || v === "sand" || v === "geyser") return "particles"
    if (v === "pulse" || v === "flame" || v === "logo") return "pulse"
    if (v === "ascii") return "ascii"
    if (v === "none") return "none"
    return "bars"
  }

  // Visualizer-specific adaptive theme color
  readonly property color activeColor: {
    if (!adaptiveColors) return defaultColor
    var v = visualizer.toLowerCase()
    switch (v) {
      case "matrix": return "#00ff66"
      case "binary": return "#00e5ff"
      case "sakura": return "#ff80ab"
      case "flame": return "#ff5722"
      case "scope": return "#76ff03"
      case "heartbeat": return "#ff1744"
      case "classicled": return "#ffab00"
      case "classicpeak": return "#ffd600"
      case "rain":
      case "bubbles": return "#40c4ff"
      case "firefly": return "#ffee58"
      case "butterfly": return "#ea80fc"
      case "firework": return "#ff4081"
      case "geyser": return "#18ffff"
      case "retro": return "#e040fb"
      default: return defaultColor
    }
  }

  // Update peak hold decay
  Timer {
    id: peakDecayTimer
    interval: 50
    repeat: true
    running: root.isPlaying && (root.category === "peak" || root.category === "bars")
    onTriggered: {
      var current = root.peakLevels.slice()
      var updated = false
      for (var i = 0; i < 10; i++) {
        var b = (root.bands && root.bands[i] !== undefined) ? root.bands[i] : 0
        if (b >= current[i]) {
          current[i] = b
          updated = true
        } else {
          current[i] = Math.max(0, current[i] - 0.04)
          updated = true
        }
      }
      if (updated) root.peakLevels = current
    }
  }

  // Request canvas paint when wave category is active
  onBandsChanged: {
    if (root.category === "wave") {
      waveCanvas.requestPaint()
    }
  }

  // --- 1. Standard Solid Bars (Bars, Columns) ---
  Row {
    id: barsRow
    visible: root.category === "bars"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Rectangle {
        required property int index
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.05, root.bands[index])) : 0.05
        width: 4
        height: Math.max(2, Math.round(val * root.height))
        anchors.bottom: parent.bottom
        radius: 1
        color: root.activeColor
        opacity: root.isPlaying ? 0.95 : 0.35

        Behavior on height {
          NumberAnimation { duration: 40; easing.type: Easing.OutQuad }
        }
      }
    }
  }

  // --- 2. Outline Bars (BarsOutline) ---
  Row {
    id: outlineRow
    visible: root.category === "outline"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Rectangle {
        required property int index
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.08, root.bands[index])) : 0.08
        width: 4
        height: Math.max(3, Math.round(val * root.height))
        anchors.bottom: parent.bottom
        radius: 1
        color: "transparent"
        border.color: root.activeColor
        border.width: 1
        opacity: root.isPlaying ? 0.9 : 0.35

        Behavior on height {
          NumberAnimation { duration: 40; easing.type: Easing.OutQuad }
        }
      }
    }
  }

  // --- 3. Peak Hold (ClassicPeak, BarsDot) ---
  Row {
    id: peakRow
    visible: root.category === "peak"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Item {
        required property int index
        width: 4
        height: root.height

        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.05, root.bands[index])) : 0.05
        readonly property real peakVal: (root.peakLevels && root.peakLevels[index] !== undefined) ? root.peakLevels[index] : val

        // Main Bar
        Rectangle {
          width: parent.width
          height: Math.max(2, Math.round(parent.val * parent.height))
          anchors.bottom: parent.bottom
          radius: 1
          color: root.activeColor
          opacity: root.isPlaying ? 0.85 : 0.3
        }

        // Peak Dot
        Rectangle {
          width: parent.width
          height: 2
          radius: 1
          y: Math.max(0, Math.round((1.0 - parent.peakVal) * (parent.height - 2)))
          color: root.activeColor
          opacity: root.isPlaying ? 1.0 : 0.0
        }
      }
    }
  }

  // --- 4. Segmented LED (ClassicLED, Bricks, Mosaic, Retro) ---
  Row {
    id: ledRow
    visible: root.category === "led"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Column {
        required property int index
        width: 4
        height: root.height
        spacing: 1
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? root.bands[index] : 0

        // 4 stacked LED blocks
        Repeater {
          model: 4
          Rectangle {
            required property int index
            // index 0 is top, 3 is bottom
            readonly property int level: 3 - index
            readonly property bool lit: parent.val > (level * 0.23)
            width: 4
            height: 3
            radius: 1
            color: lit ? (level === 3 && root.visualizer === "ClassicLED" ? "#ff3333" : (level === 2 && root.visualizer === "ClassicLED" ? "#ffbb00" : root.activeColor)) : Color.muted
            opacity: lit ? (root.isPlaying ? 0.95 : 0.3) : 0.15
          }
        }
      }
    }
  }

  // --- 5. Continuous Wave / Oscilloscope (Wave, Scope, Heartbeat, Terrain) ---
  Canvas {
    id: waveCanvas
    visible: root.category === "wave"
    anchors.fill: parent

    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      if (!root.bands || root.bands.length === 0) return

      var midY = height / 2
      var step = width / (root.bands.length - 1)

      ctx.beginPath()
      ctx.strokeStyle = root.activeColor
      ctx.lineWidth = 1.5
      ctx.lineCap = "round"
      ctx.lineJoin = "round"

      var isHeartbeat = root.visualizer.toLowerCase() === "heartbeat"

      for (var i = 0; i < root.bands.length; i++) {
        var amp = root.isPlaying ? Math.min(1.0, root.bands[i]) : 0.05
        var x = i * step
        var y = midY

        if (isHeartbeat) {
          // ECG spike simulation on strong low frequency
          if (i === 4) y = midY - amp * (height * 0.45)
          else if (i === 5) y = midY + amp * (height * 0.35)
          else y = midY
        } else {
          // Continuous smooth audio waveform curve
          var sign = (i % 2 === 0) ? -1 : 1
          y = midY + (sign * amp * (height * 0.42))
        }

        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }

      ctx.stroke()
    }
  }

  // --- 6. Digital / Binary / Matrix (Binary, Matrix) ---
  Row {
    id: digitalRow
    visible: root.category === "digital"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Column {
        required property int index
        width: 5
        spacing: 0
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? root.bands[index] : 0

        Repeater {
          model: 2
          Text {
            required property int index
            text: ((parent.index + index + (root.isPlaying ? Math.round(parent.val * 10) : 0)) % 2 === 0) ? "1" : "0"
            color: root.activeColor
            font.family: "Monospace"
            font.pixelSize: 8
            font.bold: true
            opacity: parent.val > (0.2 + index * 0.3) ? (root.isPlaying ? 1.0 : 0.3) : 0.15
          }
        }
      }
    }
  }

  // --- 7. Symmetrical / Mirrored (Mirror, Stereo, Butterfly) ---
  Row {
    id: mirrorRow
    visible: root.category === "mirror"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Item {
        required property int index
        width: 4
        height: root.height
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.08, root.bands[index])) : 0.08
        readonly property real barH: Math.max(2, Math.round(val * root.height * 0.9))

        Rectangle {
          width: parent.width
          height: parent.barH
          anchors.centerIn: parent
          radius: 1
          color: root.activeColor
          opacity: root.isPlaying ? 0.9 : 0.35

          Behavior on height {
            NumberAnimation { duration: 40; easing.type: Easing.OutQuad }
          }
        }
      }
    }
  }

  // --- 8. Particles / Drops (Rain, Sakura, Firefly, Bubbles, Firework, Sand, Geyser) ---
  Row {
    id: particlesRow
    visible: root.category === "particles"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Item {
        required property int index
        width: 4
        height: root.height
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.0, root.bands[index])) : 0.0

        // Bouncing particle dot
        Rectangle {
          width: (root.visualizer.toLowerCase() === "bubbles") ? 4 : 3
          height: width
          radius: width / 2
          anchors.horizontalCenter: parent.horizontalCenter
          y: Math.round((1.0 - parent.val) * (parent.height - height))
          color: root.activeColor
          opacity: root.isPlaying ? Math.max(0.3, parent.val) : 0.25

          Behavior on y {
            NumberAnimation { duration: 45; easing.type: Easing.OutCubic }
          }
        }
      }
    }
  }

  // --- 9. Pulse / Flame (Pulse, Flame, Logo) ---
  Row {
    id: pulseRow
    visible: root.category === "pulse"
    anchors.centerIn: parent
    spacing: 3

    Repeater {
      model: 10
      Rectangle {
        required property int index
        // Focus amplitude around center bands
        readonly property real distFromCenter: Math.abs(4.5 - index) / 4.5
        readonly property real rawVal: (root.bands && root.bands[index] !== undefined) ? root.bands[index] : 0
        readonly property real val: Math.min(1.0, Math.max(0.08, rawVal * (1.2 - distFromCenter * 0.4)))

        width: 4
        height: Math.max(2, Math.round(val * root.height))
        anchors.bottom: parent.bottom
        radius: 2
        color: root.activeColor
        opacity: root.isPlaying ? Math.max(0.4, val) : 0.3

        Behavior on height {
          NumberAnimation { duration: 40; easing.type: Easing.OutQuad }
        }
      }
    }
  }

  // --- 10. ASCII / Retro Character Block (Ascii) ---
  Row {
    id: asciiRow
    visible: root.category === "ascii"
    anchors.centerIn: parent
    spacing: 1

    readonly property var glyphs: [" ", " ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

    Repeater {
      model: 10
      Text {
        required property int index
        readonly property real val: (root.bands && root.bands[index] !== undefined) ? Math.min(1.0, Math.max(0.0, root.bands[index])) : 0.0
        readonly property int glyphIdx: Math.min(8, Math.round(val * 8))

        text: asciiRow.glyphs[glyphIdx]
        color: root.activeColor
        font.family: "Monospace"
        font.pixelSize: 11
        opacity: root.isPlaying ? 0.95 : 0.35
      }
    }
  }

  // --- 11. Minimal / Resting Mode (None) ---
  Item {
    visible: root.category === "none"
    anchors.fill: parent

    Text {
      anchors.centerIn: parent
      text: root.isPlaying ? "♫" : "·"
      color: root.activeColor
      font.pixelSize: 12
      opacity: root.isPlaying ? 0.85 : 0.4
    }
  }
}
