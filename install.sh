#!/bin/bash

# Target directories.
LIBEXEC_DIR="$HOME/.local/libexec/konsole-session"
BIN_DIR="$HOME/.local/bin"

echo "--- Installing Konsole Session Restore ---"

# 1. Create directories
mkdir -p "$LIBEXEC_DIR"

# 2. Install Executables (to libexec)
echo "Installing scripts to $BIN_DIR..."
for exe in konsole-save; do
  echo -n " $exe"
  ln -sf $PWD/$exe $BIN_DIR/$exe
done
echo
echo "Installing scripts to $LIBEXEC_DIR..."
for exe in konsole-load start-konsole-save-service; do
  echo -n " $exe"
  ln -sf $PWD/$exe $LIBEXEC_DIR/$exe
done
echo

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
