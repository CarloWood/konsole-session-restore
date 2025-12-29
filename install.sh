#!/bin/bash

# Define XDG paths with defaults.
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Target directories.
LIBEXEC_DIR="$HOME/.local/libexec/konsole-session"
UNIT_DIR="$XDG_CONFIG_HOME/systemd/user"

echo "--- Installing Konsole Session Restore ---"

# 1. Create directories
mkdir -p "$LIBEXEC_DIR"
mkdir -p "$UNIT_DIR"

# 2. Install Executables (to libexec)
echo "Installing scripts to $LIBEXEC_DIR..."
cp konsole-load konsole-save start-konsole-save-service "$LIBEXEC_DIR/"
chmod +x "$LIBEXEC_DIR"/*

# 3. Install Systemd Units (to user config)
echo "Installing systemd units to $UNIT_DIR..."
cp graphical-session.target konsole-save@.service konsole-session.service "$UNIT_DIR/"

# 4. Reload systemd daemon
echo "Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "--- Done! ---"
echo "Note: Ensure your ~/.xinitrc points to the new graphical-session.target"
