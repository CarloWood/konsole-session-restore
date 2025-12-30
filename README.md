## konsole-session-restore

A small user service that automatically saves your current Konsole session (windows/tabs and working directory per tab)
when rebooting and/or terminating the window manager and restores it the next time you start your graphical session.

State is written to `~/.konsole_state.json`.

## Installation

Run `./install.sh`.

## Enabling the service

Configure konsole to use single-process mode:
`Settings -> Configure Konsole... -> General -> Run all Konsole windows in a single process`.

Start the service `graphical-session.target` after Xorg is already running.
Optionally, stop the service if your window manager can hard-exit (while Xorg
and konsole still run). Rebooting normally should already take of that.

For example, if you are using `fluxbox`, put the following at the end of your `.xinitrc`:

```
# Make sure the user manager sees the right GUI env.
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# Start the systemd "graphical session" target (this will pull in konsole-session.service).
systemctl --user --no-block start graphical-session.target

# When fluxbox terminates, also stop graphical-session.target.
# At this point Xorg and konsole should both still be running.
fluxbox_exited() {
  # This causes konsole-save to be run and doesn't return until that is finished.
  systemctl --user stop graphical-session.target
}

# Stop graphical-session.target - in case it is still running - upon exit.
trap fluxbox_exited EXIT HUP INT TERM

# Start the Window Manager.
startfluxbox &
fb_pid=$!
wait "$fb_pid"

# The Window Manager did exit.
exit 0
```

## Debugging

- Enable verbose deferred restore logging:
```
systemctl --user edit konsole-session.service
```
and add:
```
[Service]
Environment=KONSOLE_LOAD_DEBUG=1
```

- View logs for the current boot:
```
journalctl --user -b -u konsole-session.service -o cat
```

This might not show all output of `konsole-load` however
(only from the direct process, not child processes).
To see the full (debug) output of `konsole-load` use:
```
journalctl --user -b -o cat -t konsole-load
```
