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
# Extrae usuario y contraseña anteriores.
#
extrae_datos() {
   [ -f "$1" ] || return 1
   cat "$1"
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
   local i usuario antiguo="$1"

   [ -n "$antiguo" ] && extra=" [$antiguo]"
   for i in $(seq "$INTENTOS" -1 1); do
      read -rp "Nombre de usuario ($i intentos)$extra: " usuario
      usuario="${usuario:-$antiguo}"

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
# Pregunta por la contraseña. 
#
pregunta_password() {
   local i pass1 pass2 antigua="$1"

   for i in $(seq "$INTENTOS" -1 1); do
      read -s -rp "Contraseña ($i intentos): " pass1
      echo >&2

      # Contraseña vacía implica que se conserva la anterior.
      [ -z "$pass1" ] && [ -n "$antigua" ] && echo "$antigua" && return 0

      if ! valida_password "$pass1"; then
         error 0 "La contraseña no cumple con nuestra política de seguridad"
         continue
      fi

      read -s -rp "Repita la contraseña: " pass2
      echo >&2

      [ "$pass1" = "$pass2" ] && cifrar "$pass1" && return 0
      error 0 "Las contraseñas no coinciden."
   done

   return 1
}


#
# Cifra la contraseña
#
cifrar() {
   openssl passwd -1 -salt a "$1"
}

datos=$(extrae_datos "$FICHERO")

antiguo="${datos%%:*}"
usuario=$(pregunta_usuario "$antiguo") || error 1 No se puede establecer el usuario

[ "$usuario" = "$antiguo" ] && antigua="${datos#*:}"
password=$(pregunta_password "$antigua") || error 1 No se puede establecer la contraseña

echo "$usuario:$password" > "$FICHERO"
