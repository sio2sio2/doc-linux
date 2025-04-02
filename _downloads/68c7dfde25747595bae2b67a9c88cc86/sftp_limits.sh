#!/bin/sh
#
# Script para implementar limitaciones de uso
# en el servicio sftp.
#
# Parámetros:
#
# max_per_ip=     Máximo de conexiones por ip 
# max_per_user=   Máximo de conexiones por usuario
# max_clients=    Máximo de clientes conectados.
# groups=         Grupos, sep. por comas, afectados por la limitación
# port=           Puerto en el que escucha ssh
# debug           Muestra mensajes de depuración

[ "$PAM_SERVICE" = "sshd" -a "$PAM_TYPE" = "open_session" ] || exit 0

LOGGER="[ -z \"$DEBUG\" ] && "

debug() {
   [ -n "$DEBUG" ] && logger -t sftp_limits -p authpriv.debug --id=$$ "Sesión para '$PAM_USER': $1"
}

while [ $# -gt 0 ]; do
   if [ "$1" = "debug" ]; then
      DEBUG=1
   else
      eval $1
   fi
   shift
done
[ -n "$groups" ] || groups=ftpusers
[ -n "$port" ] || port=ssh

groups=$(echo "$groups" | tr ',' '|')

if ! id -nG "$PAM_USER" | grep -qw "$groups"; then
   debug "Usuario no limitado"
   exit 0
fi

if [ -n "$max_per_user" ]; then
   # Número de sesiones por cliente
   NUMSESSIONS=$(pgrep -c -u "$PAM_USER" sshd)
   NUMSESSIONS=$((NUMSESSIONS/2+1))
   debug "Sesión de usuario $NUMSESSIONS/$max_per_user"
   if [ $NUMSESSIONS -gt $max_per_user ]; then
      debug "Excedido el máximo para $PAM_USER"
      exit 1
   fi
fi

if [ -n "$max_per_ip" ]; then
   NUMSESSIONS=$(ss -tH state established "sport = :$port and dst $PAM_RHOST" | wc -l)
   debug "Sesión para $PAM_RHOST $NUMSESSIONS/$max_per_ip"
   if [ $NUMSESSIONS -gt $max_per_ip ]; then
      debug "Excedido el máximo para el cliente $PAM_RHOST"
      exit 1
   fi
fi

if [ -n "$max_clients" ]; then
   NUMSESSIONS=$(ss -H state established "( sport = :$port )" | wc -l)
   debug "Sesión $NUMSESSIONS/$max_clients"
   if [ $NUMSESSIONS -gt $max_clients ]; then
      debug "Excedido el máximo total de sesiones"
      exit 1
   fi
fi

exit 0
