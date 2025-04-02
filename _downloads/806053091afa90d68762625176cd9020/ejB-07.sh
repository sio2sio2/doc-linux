#!/bin/sh

FICHERO="$HOME/vpasswd"
INTENTOS=3

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
   local i usuario

   for i in $(seq "$INTENTOS" -1 1); do
      read -rp "Nombre de usuario ($i intentos): " usuario

      valida_usuario "$usuario" && echo "$usuario" && return 0
      error 0 "Usuario incorrecto"
   done

   return 1
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
   local i pass1 pass2

   for i in $(seq "$INTENTOS" -1 1); do
      read -s -rp "Contraseña ($i intentos): " pass1
      echo >&2
      if ! valida_password "$pass1"; then
         error 0 "La contraseña no cumple con nuestra política de seguridad"
         continue
      fi

      read -s -rp "Repita la contraseña: " pass2
      echo >&2

      [ "$pass1" = "$pass2" ] && echo "$pass1" && return 0
      error 0 "Las contraseñas no coinciden."
   done

   return 1
}


cifrar() {
   openssl passwd -1 -salt a "$1"
}


case $1 in
   "") ;;
   c) cifrar="1" ;;
   *) echo "$1: Parámetro desconocido"  >&2 
      exit 2 ;;
esac

usuario=$(pregunta_usuario) || error 1 No se puede establecer el nombre de usuario
password=$(pregunta_password) || error 1 No se puede establecer la contraseña

[ -n "$cifrar" ] && password=$(cifrar "$password")


echo "$usuario:$password" >> "$FICHERO"
