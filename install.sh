#!/bin/bash
# Installs cliamp-bar-widget (Cliamp Visualizer bar widget) for Omarchy.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

PLUGIN_ID="bol.cliamp-bar"
PLUGIN_DEST="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

command -v omarchy >/dev/null 2>&1 || { echo "omarchy CLI not found; this installer only supports Omarchy."; exit 1; }
command -v cliamp >/dev/null 2>&1 || echo "Warning: 'cliamp' is not installed yet. Install it with: sudo pacman -S cliamp"

echo "Validating plugin manifest..."
omarchy plugin validate "$SCRIPT_DIR"

echo "Installing plugin to $PLUGIN_DEST ..."
mkdir -p "$HOME/.config/omarchy/plugins"

# Remove existing installation (whether directory or symlink)
if [[ -L "$PLUGIN_DEST" || -d "$PLUGIN_DEST" ]]; then
  rm -rf "$PLUGIN_DEST"
fi

mkdir -p "$PLUGIN_DEST"

# Copy plugin files (direct files, no symlink)
cp "$SCRIPT_DIR/manifest.json" "$PLUGIN_DEST/"
cp "$SCRIPT_DIR/BarWidget.qml" "$PLUGIN_DEST/"
cp "$SCRIPT_DIR/CliampService.qml" "$PLUGIN_DEST/"
cp "$SCRIPT_DIR/VisualizerRenderer.qml" "$PLUGIN_DEST/"
if [[ -f "$SCRIPT_DIR/README.md" ]]; then
  cp "$SCRIPT_DIR/README.md" "$PLUGIN_DEST/"
fi

echo "Rescanning & enabling the plugin in the Omarchy shell..."
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
omarchy plugin enable "$PLUGIN_ID" --section center >/dev/null 2>&1 || true
omarchy restart shell >/dev/null 2>&1 || true

cat <<EOF

Done! Cliamp Bar Widget successfully installed to:
  $PLUGIN_DEST

Controls:
- Left-click: Play / Pause (or launch cliamp if closed)
- Right-click: Next visualizer (cycles through all 31 visualizers)
- Middle-click: Next track
- Scroll wheel: Change display mode:
    1: Playback + Visualizer
    2: Visualizer only
    3: Playback only
- Auto-hide: Widget automatically hides (0 px) when cliamp is closed.
EOF
