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
for exe in konsole-load fluxbox-exit; do
  echo -n " $exe"
  ln -sf $PWD/$exe $LIBEXEC_DIR/$exe
done
echo

echo "--- Done! ---"
