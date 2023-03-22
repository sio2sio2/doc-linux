#!/bin/sh

MPVDIR=${XDG_CONFIG_HOME:-$HOME/.config}/mpv/

[ -d "$MPVDIR/watch_later" ] || exit 0

find "$MPVDIR/watch_later" -type f -mtime +30 -delete
