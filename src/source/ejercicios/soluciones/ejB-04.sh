#!/bin/sh

FICHERO="vpasswd"

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


cifrar() {
   openssl passwd -1 -salt a "$1"
}


case $1 in
   "") ;;
   c) cifrar="1" ;;
   *) echo "$1: Parámetro desconocido"  >&2 
      exit 2 ;;
esac

read -p "Nombre de usuario: " usuario
read -s -p "Contraseña: " password
echo

[ -n "$cifrar" ] && password=$(cifrar "$password")


echo "$usuario:$password" >> ~/$FICHERO
