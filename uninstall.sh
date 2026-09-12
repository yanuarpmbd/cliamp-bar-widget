#!/bin/bash
# Uninstalls cliamp-bar-widget for Omarchy.
set -euo pipefail

PLUGIN_ID="bol.cliamp-bar"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

echo "Removing the widget from the Omarchy plugin registry..."
omarchy plugin remove "$PLUGIN_ID" --yes 2>/dev/null || true

if [[ -L "$PLUGIN_DIR" || -d "$PLUGIN_DIR" ]]; then
  echo "Removing plugin directory $PLUGIN_DIR ..."
  rm -rf "$PLUGIN_DIR"
fi

echo "Rescanning Omarchy plugins and restarting shell..."
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
omarchy restart shell >/dev/null 2>&1 || true

echo "Done! Cliamp Bar Widget uninstalled successfully."
