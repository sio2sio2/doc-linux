#!/bin/sh

STATEDIR=${XDG_STATE_HOME:-$HOME/.local/state}

[ -d "$STATEDIR/mpv/watch_later" ] || exit 0

find "$STATEDIR/mpv/watch_later" -type f -mtime +30 -delete
