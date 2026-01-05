## konsole-session-restore

Save your current konsole Session (windows, tabs and working directory per tab)
and restore it the next time you login.

State is written to `~/.konsole_state.json`.

## Installation

Run `./install.sh`.

## System configuration

Configure `konsole` to use single-process mode:
`Settings -> Configure Konsole... -> General -> Run all Konsole windows in a single process`.

### konsole-load

konsole-load starts `konsole` and restores tabs via Konsole's DBus API (`qdbus`),
therefore it requires the environment variables DBUS_SESSION_BUS_ADDRESS, DISPLAY and XAUTHORITY to be set.

A display manager like lightdm will eventually start a window manager from /usr/share/xsessions.
For example, in the case of fluxbox there is a /usr/share/xsessions/fluxbox.desktop that starts
`/usr/bin/startfluxbox`, a script that basically exec's `$HOME/.fluxbox/startup`. Also `~/.xinitrc`
exec's `/usr/bin/startfluxbox`.

Assuming you are using fluxbox, best practise is run `konsole-load` from `$HOME/.fluxbox/startup`.
For example,

```
# Applications you want to run with fluxbox.
gkrellm &
/usr/bin/dunst &
# etc
KONSOLE_LOAD_DEBUG=1 $HOME/.local/libexec/konsole-session/konsole-load
exec fluxbox
```

By starting it there, we are sure that Xorg is already running and DISPLAY and XAUTHORITY are useable.

Of course, once everything works you don't need the `KONSOLE_LOAD_DEBUG=1`.

### konsole-save

Saving the session state is done by running `konsole-save`, which should be in your
PATH (assuming you have `$HOME/.local/bin` in your PATH).

Automating that this being run upon logout turns out to be non-trivial: while it is
acceptable that the window manager did just terminate, Xorg and the konsole process
should still be running; moreover konsole-save *does* use wmctrl.

For example, running it from lightdm's session-cleanup-script turned out not to work
because at that moment the users X cookie has already been revoked.

What I did for fluxbox is to change the `[exit]` entry in `~/.fluxbox/menu` form
```
  [exit] (Exit)
```
into:
```
  [exec] (Exit) {/home/carlo/.local/libexec/konsole-session/fluxbox-exit}
```
Note that `$HOME/.local/libexec/konsole-session/fluxbox-exit` is also installed
by this project. This tiny script first runs `konsole-save` and then uses
fluxbox-remote to send the exit command.

## Debugging

- View the most recent logs of `konsole-save`:
```
journalctl --user -b -t konsole-save | awk -v s='konsole-save starting' 'index($0, s) { buf = "" } { buf = buf $0 ORS } END { printf "%s", buf }'
```
This only shows messages from the current boot - so if you just rebooted you might need to pass `-b -1` to `journalctl` instead.

To see the most recent logs of `konsole-load` use:
```
journalctl --user -b -t konsole-load | awk -v s='Loading ' 'index($0, s) { buf = "" } { buf = buf $0 ORS } END { printf "%s", buf }'
```
The PID of `konsole-load` will change at `apply_window_properties` because that is executed defered, as separate user service.
