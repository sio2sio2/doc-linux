#!/bin/sh

HOMEDIR_BASE=${HOMEDIR_BASE:-/srv/ftp}
GRUPO_PRI=""${GRUPO_PRI:-ftpusers}
PASSWORD=1 
INTENTOS_MAX=${INTENTOS_MAX:-3}


soy_root() {
   [ "$(id -u)" -eq 0 ]
}


error() {
   local EXITCODE="$1"
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "¡Atención! "$* >&2
   else
      echo "ERROR. "$* >&2
      exit "$EXITCODE"
   fi
}


read() {
   local settings

   if [ "$1" = "-s" ]; then
      shift
      settings=$(stty -g)
      stty -echo
   fi

   IFS= command read "$@"

   [ -n "$settings" ] && stty "$settings"
}


#
# Comprueba si un usuario existe.
# $1: Nombre de usuario
#
existe_usuario() {
   id "$1" >/dev/null 2>&1 
}


#
# Comprueba si existe un grupo
# $1: Nombre del grupo
#
existe_grupo() {
   getent group "$1" > /dev/null
}


{ # Creación de usuarios/grupos.
  # La implementación depende del tipo de usuario.
   #
   # Crea un grupo de sistema.
   # $1: Nombre del grupo
   #
   crea_grupo() {
      addgroup --system "$1"
   }

   #
   # Crea un usuario
   # $1: Nombre de usuario
   # $2: Grupo primario
   # $3: Directorio personal
   #
   crea_usuario() {
      adduser --home "$3" --gecos "$1 (Usuario FTP)" --ingroup "$2" --disabled-password "$1"
   }

   #
   # Cambia la contraseña
   # $1: Usuario
   # $2: Contraseña
   #
   establece_password() {
      echo "$1:$2" | chpasswd
   }
}


#
# Pregunta por el nombre de usuario
#
pregunta_usuario() {
   local i usuario

   for i in $(seq "$INTENTOS_MAX" -1 1); do
      read -rp "Nombre de usuario ($i intentos): " usuario

      if [ -z "$usuario" ]; then
         error 0 "'$usuario': Usuario incorrecto"
      elif existe_usuario "$usuario"; then
         error 0 "'$usuario': El usuario ya existe"
      else
         echo "$usuario"
         return 0
      fi
   done

   return 1
}


#
# Pregunta por la contraseña
#
pregunta_password() {
   local i pass1 pass2

   for i in $(seq "$INTENTOS_MAX" -1 1); do
      read -s -rp "Contraseña ($i intentos): " pass1
      echo >&2
      read -s -rp "Repita la contraseña: " pass2
      echo >&2

      [ "$pass1" = "$pass2" ] && echo "$pass1" && return 0
      error 0 "Las contraseñas no coinciden."
   done

   return 1
}


soy_root || error 1 "Debe ser administrador"

[ "$1" = "--no-password" ] && unset PASSWORD

echo "Programa para crear usuarios FTP."
echo

NOMBRE=$(pregunta_usuario) || error 1 "No se puede fijar el usuario"

if [ -n "$PASSWORD" ]; then
   PASS=$(pregunta_password) || error 1 "Imposible establecer una contraseña"
fi

existe_grupo "$GRUPO_PRI" || crea_grupo "$GRUPO_PRI"

crea_usuario "$NOMBRE" "$GRUPO_PRI" "$HOMEDIR_BASE/$NOMBRE"
[ -n "$PASSWORD" ] && establece_password "$NOMBRE" "$PASS"
