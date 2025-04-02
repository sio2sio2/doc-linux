#!/bin/sh
#
# Cuando actualiza la clave, copia
# la clave para que pueda usarla haproxy.
#

DOMAINS="www.infomiravent.es"
HAPROXYDIR="/etc/haproxy"
LETSENCRYPTDIR=$(readlink -f `dirname $0`)
UPDATE=0

for domain in $DOMAINS; do
   dir="$LETSENCRYPTDIR/live/$domain/" 
   [ -d "$dir" ] || continue
   # ¿Se ha actualizado la clave?
   /usr/bin/test "$dir"/fullchain.pem -nt "$HAPROXYDIR/$domain".pem || continue
   cat "$dir"/fullchain.pem "$dir"/privkey.pem > "$HAPROXYDIR/$domain".pem
   chmod 600 "$HAPROXYDIR/$domain".pem
   UPDATE=1
done

[ $UPDATE -eq 1 ] && systemctl reload-or-restart haproxy
