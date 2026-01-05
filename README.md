## konsole-session-restore

A small user service that automatically saves your current Konsole session (windows/tabs and working directory per tab)
when rebooting and/or terminating the window manager and restores it the next time you start your graphical session.

State is written to `~/.konsole_state.json`.

## Installation

Run `./install.sh`.

## Enabling the service

Configure konsole to use single-process mode:
`Settings -> Configure Konsole... -> General -> Run all Konsole windows in a single process`.

`konsole-session.service` can not be started by using `WantedBy=default.target` because
it runs `konsole` and restores tabs via Konsole's DBus API (`qdbus`), so
DBUS_SESSION_BUS_ADDRESS, DISPLAY and XAUTHORITY must be set for the user service;
which isn't the case yet when the main user target comes up.

If you are using `.xinitrc` then make sure it sources `.xprofile`.
A display manager, like lightdm, will source `.xprofile` too.

Then add the following to `~/.xprofile`:
```
# Give the user manager the required session variables.
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
# Start the konsole-session service.
systemctl --user --no-block start konsole-session.service
```

## Debugging

- Enable verbose load and/or save logging:
```
systemctl --user edit konsole-session.service
```
and add:
```
[Service]
Environment=KONSOLE_LOAD_DEBUG=1
Environment=KONSOLE_SAVE_DEBUG=1
```

And `systemctl --user daemon-reload`.
Remove again with `systemctl --user revert konsole-session.service` (this removes ALL edits made).

- View logs for the current boot:
```
journalctl --user -b -u konsole-session.service -o cat \
  | awk -v s='Starting konsole session store/restore service' 'index($0, s) { buf = "" } { buf = buf $0 ORS } END { printf "%s", buf }'
```

This might not show all output of `konsole-load` however
(only from the direct process, not child processes).
To see the full (debug) output of `konsole-load` use:
```
journalctl --user -b -t konsole-load \
  | awk -v s='(windows before: )' 'index($0, s) { buf = "" } { buf = buf $0 ORS } END { printf "%s", buf }'
```
The PID of `konsole-load` will change at `apply_window_properties` because that is executed defered, as separate user service.
