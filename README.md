## konsole-session-restore

A small user service that automatically saves your current Konsole session (windows/tabs and working directory per tab)
when rebooting and/or terminating the window manager and restores it the next time you start your graphical session.

State is written to `~/.konsole_state.json`.

## Installation

Run `./install.sh`.

## Enabling the service

You need some kind of Display Manager, for example `lightdm`.
That starts up because the system reaches `graphical.target`.
```
systemctl set-default graphical.target
```

Configure konsole to use single-process mode:
`Settings -> Configure Konsole... -> General -> Run all Konsole windows in a single process`.

`konsole-session.service` is started because it was enabled (by install.sh) and
because it has `WantedBy=default.target` under `[Install]`, where `default.target`
should be what `systemctl --user get-default` returns in your case (although `default.target`
probably also keep working if you changed that).

`konsole-load` restores tabs via Konsole's DBus API (`qdbus`),
so DBUS_SESSION_BUS_ADDRESS/DISPLAY/XAUTHORITY must be set for the user service.

For example, if you are using `.xinitrc` add the following lines to it:

```
# Make sure the user manager sees the right GUI env.
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
```

## Debugging

- Enable verbose store logging:
```
systemctl --user edit konsole-save@.service
```
and add:
```
[Service]
Environment=KONSOLE_SAVE_DEBUG=1
```

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
