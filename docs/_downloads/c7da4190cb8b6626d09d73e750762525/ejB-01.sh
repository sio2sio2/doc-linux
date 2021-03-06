#!/bin/sh

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

read -p "Nombre de usuario: " usuario
read -s -p "Contraseña: " password
echo

echo "Ha escogido para indentificarse $usuario/$password"
