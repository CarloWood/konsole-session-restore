#!/bin/bash

# Target directories.
LIBEXEC_DIR="$HOME/.local/libexec/konsole-session"

echo "--- Installing Konsole Session Restore ---"

# 1. Create directories
mkdir -p "$LIBEXEC_DIR"

# 2. Install Executables (to libexec)
echo "Installing scripts to $LIBEXEC_DIR..."
cp konsole-load konsole-save start-konsole-save-service "$LIBEXEC_DIR/"
chmod +x "$LIBEXEC_DIR"/*

# 3. Install Systemd Units (to user config)
echo -n "Linking systemd units..."
for unit in graphical-session.target konsole-session.service konsole-save@.service; do
  echo -n " $unit"
  systemctl --user link "$PWD/$unit"
done
echo

# 4. Enable konsole-session.service or it won't be started when graphical-session.target comes up.
echo "Enabling konsole-session.service..."
systemctl --user enable konsole-session.service

# 4. Reload systemd daemon
echo "Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "--- Done! ---"
echo "Note: Ensure your ~/.xinitrc points to the new graphical-session.target"
