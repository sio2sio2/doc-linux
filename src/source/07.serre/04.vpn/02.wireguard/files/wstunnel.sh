#!/bin/sh
#

ACTION=$1
IFACE=$2
DEFAULT_PORT=51820

help() {
   echo "$(basename $0) up|down|route <interfaz>:
   Establece un tunel websocket para wireguard

Opciones:

up|down|route     Acción.
<interfaz>        Nombre de la interfaz.

Los ficheros de configuración deben llamarse interfaz.wstunnel.

En el servidor:

   #SECURE=1    # Para wss, por defecto ws.
   LISTEN_ADDRESS=127.0.0.1  # Por defecto, 0.0.0.0
   #LISTEN_PORT=443     # Puerto de escucha, por defecto 80/443 dependiendo de SECURE.

En el cliente:

   SECURE=1    # Para wss, por defecto ws
   RHOST=203.0.113.1  # Dirección del servidor. Puede añadirse puerto, si no es 80 o 443.
   WG_PORT=1194  # Puerto donde escucha el wireguard servidor. Por defecto 51820.

"
}


error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "Atención: " $* >&2
   else
      echo "ERROR: " $* >&2
      exit "$EXITCODE"
   fi
}


#
# Lanza un proceso en segundo plano
# $@: La línea que debe lanzarse.
#
lanzar_proceso() {
   local pid pidfile="/var/run/wstunnel.$IFACE.pid"

   if [ -f "$pidfile" ]; then
      pid=$(cat "$pidfile")
      error 1 "Ya hay un tunel establecido para la interfaz $IFACE: pid $pid"
   fi

   nohup "$@" > /dev/null &
   echo "$!" > "$pidfile"
}


#
# up-servidor
#
up_server() {
   local server_port proto

   if [ "$SECURE" = 1 ] && [ "$LISTEN_ADDRESS" != "127.0.0.1" ]; then
      proto="wss"
   else
      proto="ws"
   fi

   server_port=$(awk -F ' *= *' '$1 == "ListenPort" {print $2}' "$CONF")
   [ -n "$server_port" ] || error 1 "El servidor no define ningún puerto de escucha"

   lanzar_proceso wstunnel -q \
                  --server "$proto://${LISTEN_ADDRESS:-0.0.0.0}${LISTEN_PORT:+:$LISTEN_PORT}" \
                  --restrictTo "127.0.0.1:$server_port"
}


#
# up-client
#
up_client() {
   local proto endpoint

   if [ "$SECURE" = 1 ]; then
      proto="wss"
   else
      proto="ws"
   fi

   endpoint=$(awk -F ' *= *' '$1 == "Endpoint" {print $2}' "$CONF")

   lanzar_proceso wstunnel -q --udp --udpTimeoutSec -1 \
                  -L "$endpoint:127.0.0.1:${WG_PORT:-$DEFAULT_PORT}" \
                  $proto://$RHOST$WPATH
}

#
# down...
#
down() {
   local pid pidfile="/var/run/wstunnel.$IFACE.pid"
   local table=$DEFAULT_PORT

   if [ -f "$pidfile" ]; then
      pid=$(cat "$pidfile")
      kill -TERM "$pid"
      rm -f "$pidfile"
   else
      error 1 "No parece haber túnel establecido para la interfaz $IFACE"
   fi

   [ -n "$RHOST" ] && ip route flush table "$DEFAULT_PORT" 2>/dev/null
}


#
# route...
#
route() {
   local gateway routes table=$DEFAULT_PORT
   
   # ¿Ha creado rutas adicionales wg-quick?
   routes=$(ip route show table "$table" 2>/dev/null)
   [ -n "$routes" ] || return 0

   gateway=$(ip route show | awk '/^default/ {print $3, $5}')
   ip route add "${RHOST%:*}" via "${gateway% *}" dev "${gateway#* }" table "$table"
}


#
# Programa principal
#
command -v wstunnel > /dev/null
if [ $? -ne 0 ]; then
   error 1 "wstunnel no se encuentra en el PATH"
fi

[ -n "$ACTION" ] || error 2 "No ha indicado acción"
[ -n "$IFACE" ] || error 2 "No ha indicado interfaz virtual"

CONF="/etc/wireguard/$IFACE.conf"
[ -f "$CONF" ] || error 1 "No existe configuración para $IFACE"

TCONF="/etc/wireguard/$IFACE.wstunnel"
[ -f "$TCONF" ] && . "$TCONF"


case "$ACTION" in
   up) 
      if [ -z "$RHOST" ]; then  # Servidor
         up_server
      else
         up_client
      fi
      ;;
   down) down ;;
   route) 
      [ -z "$RHOST" ] && error 1 "La acción route no tiene sentido en un servidor"
      route;;
   *) error 1 "Acción '$ACTION' desconocida"
esac

exit 0
