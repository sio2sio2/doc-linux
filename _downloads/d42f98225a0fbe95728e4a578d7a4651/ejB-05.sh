#!/bin/sh

FICHERO="$HOME/vpasswd"

#
# Wrapper que añade -s a la orden "read".
# (Con bash no hace falta definir esta función)
#
read() {
   local settings

   if [ "$1" = "-s" ]; then
      shift
      settings=$(stty -g)
      stty -echo
   fi

   IFS= command read -r "$@"

   [ -n "$settings" ] && stty "$settings"
}


#
# Imprime un mensaje de error y sale
# $1: Código de salida
# $2: Mensaje de error
#
error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "¡Atención! $*" >&2
   else
      echo "ERROR. $*" >&2
      exit "$EXITCODE"
   fi
}


#
# Comprueba que el usuario cumpla con la politica de nombres
# $1: La contraseña a validad.
# return: 0 si es válida; 1 si no lo es.
#
valida_usuario() {
   [ -n "$1" ]
}


#
# Pregunta por el nombre de usuario
#
pregunta_usuario() {
   local usuario

   while true; do
      read -rp "Nombre de usuario: " usuario

      valida_usuario "$usuario" && break
      error 0 "Usuario incorrecto"
   done

   echo "$usuario"
}


#
# Comprueba que la contraseña cumple con nuestra política de seguridad
# $1: La contraseña a validad.
# return: 0 si es válida; 1 si no lo es.
#
valida_password() {
   # Como el enunciado no establece ninguna, acepto cualquiera.
   return 0
}


#
# Pregunta por la contraseña
#
pregunta_password() {
   local pass1 pass2

   while true; do
      read -s -rp "Contraseña: " pass1
      echo >&2
      if ! valida_password "$pass1"; then
         error 0 "La contraseña no cumple con nuestra política de seguridad"
         continue
      fi
      read -s -rp "Repita la contraseña: " pass2
      echo >&2

      [ "$pass1" = "$pass2" ] && break
      error 0 "Las contraseñas no coinciden."
   done

    echo "$pass1"
}


case $1 in
   "") ;;
   c) cifrar="1" ;;
   *) echo "$1: Parámetro desconocido"  >&2 
      exit 2 ;;
esac


usuario=$(pregunta_usuario) || error 1 "Usuario incorrecto"
password=$(pregunta_password) || error 1 "Las contraseñas no coinciden"

[ -n "$cifrar" ] && password=$(openssl passwd -1 -salt a "$password")

echo "$usuario:$password" >> "$FICHERO"
