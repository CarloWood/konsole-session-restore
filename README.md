# Installation

Run `./install.sh`.

# Enabling the service

Configure konsole to use single-process mode.
`Settings -> Configure Konsole... -> General -> Run all Konsole windows in a single process.

Start and the service `graphical-session.target` after Xorg is already running.
Optionally, stop the service if your window manager can hard-exit (while Xorg
and konsole still run).

For example, of you are using `fluxbox`, put the following at the end of your `.xinitrc`:

```
# Make sure the user manager sees the right GUI env.
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# Start the systemd "graphical session" target (this will pull in konsole-session.service).
systemctl --user start graphical-session.target

# When fluxbox terminates, also stop graphical-session.target.
# At this point Xorg and konsole should both still be running.
fluxbox_exited() {
  systemctl --user stop graphical-session.target
}

trap fluxbox_exited EXIT HUP INT TERM

startfluxbox &
fb_pid=$!
wait "$fb_pid"

# Stop graphical-session.target - in case it is still running.
exit 0
```


