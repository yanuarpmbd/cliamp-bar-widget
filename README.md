# Cliamp Bar Widget for Omarchy

A top bar widget for **Omarchy Shell** (powered by Quickshell) that provides real-time audio spectrum visualization and playback controls for the **cliamp** terminal music player.

The widget dynamically adapts its visualization graphics to match **all 31 built-in visualizers of cliamp** in real time.

---

## Key Features

- **Adaptive 31 Visualizers**:
  Reads the NDJSON stream from `cliamp visstream` and dynamically switches rendering styles to match the active visualizer in cliamp:
  - **Bars & Columns**: Solid vertical equalizer bars.
  - **BarsOutline**: Outlined hollow bars.
  - **ClassicPeak & BarsDot**: Vintage VU equalizer with peak hold dots decaying under gravity.
  - **ClassicLED, Bricks & Mosaic**: Segmented tiered retro LED lights.
  - **Wave, Scope & Heartbeat**: Continuous oscilloscope waveform curves and ECG pulses.
  - **Binary & Matrix**: Digital binary columns (`0 1`) and glowing matrix code.
  - **Mirror, Stereo & Butterfly**: Vertically and horizontally mirrored bars.
  - **Particles (Rain, Sakura, Firefly, Bubbles, Firework, Scatter, Sand, Geyser)**: Floating and bouncing particle dots driven by audio amplitude.
  - **Pulse & Flame**: Dynamic amplitude pulsing and warm fire glows.
  - **Ascii**: Unicode terminal block characters (` ▂▃▅▆▇█`).
  - **None**: Minimalist resting mode.
- **Thematic Adaptive Colors**:
  Automatically adapts accent colors to match the active visualizer theme (e.g., Matrix green, Sakura pink, Flame orange, Cyber cyan, Phosphor green, Amber LED) or falls back to Omarchy's system accent color.
- **Track Metadata**:
  Displays the current track title alongside the visualizer, with a rich hover tooltip (title, artist, status, active visualizer mode, and display mode).
- **Full Mouse Controls**:
  - **Left Click**: Toggle Play / Pause (`cliamp toggle`). If cliamp is not running, launches cliamp.
  - **Right Click**: Switch to the next visualizer (`cliamp vis next`) — synchronized bi-directionally between the bar and cliamp TUI.
  - **Middle Click**: Next track (`cliamp next`).
  - **Scroll Wheel**: Switch display modes (1: Playback + Visualizer, 2: Visualizer only, 3: Playback only).
- **3 Display Modes**:
  1. **Playback + Visualizer** *(Default)*: Shows status icon, track title, and active visualizer.
  2. **Visualizer Only**: Clean and compact, shows only the visualizer bars.
  3. **Playback Only**: Shows status icon and track title without visualizer bars.
- **Smart Idle & Auto-Hide (Zero Bar Space when Closed)**:
  When cliamp is closed, the widget automatically hides and shrinks to **0 pixels**, releasing all space for neighboring widgets. Audio streaming is automatically paused when playback stops.

---

## Installation

Run the installer script:
```bash
./install.sh
```
The installer validates the manifest, copies the plugin files directly to `~/.config/omarchy/plugins/bol.cliamp-bar/` (no symlinks), rescans plugins, and enables the widget in Omarchy.

### Uninstallation
To remove the plugin from Omarchy:
```bash
./uninstall.sh
```

### (Optional) Adjust Bar Position
Open `~/.config/omarchy/shell.json` or run:
```bash
omarchy bar move bol.cliamp-bar center 0
```

---

## Configuration Options (`shell.json`)

Configure the widget in your `~/.config/omarchy/shell.json` layout entry:
```json
{
  "id": "bol.cliamp-bar",
  "fps": 20,
  "showTrack": true,
  "maxTitleLength": 24,
  "adaptiveColors": true,
  "autoHide": true,
  "displayMode": 1
}
```

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `fps` | number | `20` | Spectrum rendering frame rate (10 - 30). |
| `showTrack` | boolean | `true` | Show track title next to the visualizer. |
| `maxTitleLength` | number | `24` | Maximum track title character length before truncation (`…`). |
| `adaptiveColors` | boolean | `true` | Use visualizer-specific thematic accent colors. |
| `autoHide` | boolean | `true` | Automatically hide widget (0 px) when cliamp is closed. |
| `displayMode` | number | `1` | Default display mode: `1` (Both), `2` (Visualizer only), `3` (Playback only). |

---

## Shell IPC Integration

The widget registers an IPC handler (`cliamp-bar`) accessible via `quickshell ipc` or keybindings:
```bash
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar toggle
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar nextVis
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar next
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar prev
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar cycleMode
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar setMode 2
```
