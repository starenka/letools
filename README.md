# letools

Small single-purpose CLI tools, mostly used as `awful.spawn` targets from
[my AwesomeWM config](https://github.com/starenka/awesomerc) (or wherever
else — they're plain standalone scripts). Everything here is assumed to be
on `$PATH` (see Install below) rather than invoked by absolute path.

## Install

```
just install
```

Symlinks every tool into `~/bin/<name>`. Re-run after pulling changes; it's
idempotent (`ln -sf`).

## Tools

### brightness

Screen backlight control via `brightnessctl`.

```
brightness up|u      # +3%, or straight to 100% if currently very low
brightness down|d    # -3%
```

Requires `brightnessctl` (`apt install brightnessctl`).

### monitor

External/builtin display switching via `xrandr`, with per-Wi-Fi-network
resolution presets for the external monitor.

```
monitor external|e     # turn on external display
monitor integrated|i   # turn on builtin display (aliases: b, d)
monitor don            # external on + builtin off, then awesome.restart()
monitor doff           # builtin on + external off, then awesome.restart()
```

Override without editing the script: `BUILTIN_RES` sets the builtin panel's
`xrandr --mode` (default `1680x1050`); `MONITOR_WIFI_RES="SSID1=RES1,SSID2=RES2"`
merges into (and can override) the built-in per-SSID resolution table.

### player

`playerctl` wrapper defaulting to a specific player (`dog.unix.cantata.Cantata`
— override with the `PLAYER` env var, e.g. `PLAYER=org.mpris.MediaPlayer2.foo
player playpause`, or edit the default in the script).

```
player playpause | next | prev | stop
player volume-up | volume-down
player current   # prints "title - artist"
```

### volume

PulseAudio volume control via `pactl`, plus player-specific volume via
`playerctl` (hardcoded to `cantata` — edit `PLAYER` in the script).

```
volume level | l      # prints e.g. "42%" or "42M" if muted
volume up | u          # +2dB (capped, won't go above ~110%)
volume down | d        # -2dB
volume mute | m         # toggle mute
volume player-up | player-down
```

### alarm

Schedules a `notify-send` notification for a future time via a transient
`systemd --user` timer (`systemd-run --on-calendar=...`) — the scheduling
lives in systemd, not in a sleeping process, so it survives the shell that
launched it and the machine suspending.

```
alarm TIME MESSAGE [TITLE]
```

`TIME` is one of:

```
+30m | +2h | +1d | +1w          relative offset (units: s/m/h/d/w)
"tomorrow HH:MM[:SS]"           next calendar day at that wall-clock time
2026-09-20T21:00[:00]           ISO 8601 datetime
```

`TITLE` defaults to `"alarm"`. Requires `notify-send` and a running
`systemd --user` instance.

### repls

`fzf` menu to launch a REPL: python (`uvx ipython`), js (`bun repl`), lua,
ruby, perl, php, clojure (`bb`/babashka), java (`jshell`), elisp
(`emacs`/ielm), go (`gore`), or rust (`evcxr`). Add/remove entries via the
`REPLS` table in the script.

```
repls
```

Requires `fzf`. Each entry needs its own interpreter on `PATH` (`uv`/`uvx`
for python, `bun` for js, `bb` for clojure, etc — see `REPLS` for the exact
command each label runs).

### rae_wotd

Fetches the Real Academia Española "word of the day" and caches it at
`~/.cache/rae_wotd/wotd-<date>.html` (one network call per day, subsequent
calls that day just print the cached path).

```
rae_wotd
```

A `uv`-run script (see the shebang) — `requests` is declared inline as a
dependency, no separate install step beyond having `uv` on PATH.

### startup

X session bootstrap: clears `~/.xsession-errors`, remaps a key to Menu,
swaps caps-lock for ctrl, disables screensaver/DPMS, sets key repeat rate,
then prompts (via `cowsay`) to `ssh-add` your keys and `su -` for a root
shell kept open in a terminal. Meant to be launched once per X session (e.g.
`kitty --start-as maximized startup` from an autostart list), not run
standalone.

```
startup
```

### weather

Unobtrusive weather data fetcher for a fixed location — current temp, rain
probability/amount, and an hourly forecast — with pluggable providers
(Open-Meteo, Meteosource, ČHMÚ's ALADIN model) and on-disk caching. Prints
normalized JSON to stdout; pair it with a UI (e.g. an AwesomeWM widget) that
just calls it and reads the result.

A `uv`-run script (see the shebang) — dependencies are declared inline, no
separate install step beyond having `uv` on PATH.

```
weather                      # fetch + print current weather as JSON
weather --force              # bypass cache_interval, always fetch live
weather location             # show the currently configured location
weather location "Query"     # geocode a place name and save it
weather provider             # show the currently active provider
weather provider <name>      # switch provider (open-meteo/meteosource/aladin)
```

Config lives in `weather.toml` next to the script (copy `weather.toml.example`
to get started — see that file for the full schema, including where to get
free API keys for Mapy.com geocoding and Meteosource). `weather.toml` and
`.weather-cache/` are gitignored since they hold live API keys and
location/forecast state.
