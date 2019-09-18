#!/bin/sh

GRUPO1="smr1"
GRUPO2="smr2"


error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "¡Atención!" $* >&2
   else
      echo "ERROR." $* >&2
      exit "$EXITCODE"
   fi
}


soy_root() {
   [ "$(id -u)" -eq 0 ]
}


#
# Convierte caracteres no ingleses:
# José Martín => Jose Martin
#
desacentua() {
   echo "$@" | iconv -f utf8 -t ascii//TRANSLIT
}

#
# Crea el nick del usuario
# $1: Nombre real.
# $2: NIF
#
crea_nick() {
   # Transformamos caracteres no ingleses
   local nombre="$(desacentua $1)"
   local inicial nif="$2" digitos

   # Eliminamos del nombre partículas como "de". Por ejemplo:
   # Miguel de la Quadra-Salcedo y Gayarre => Miguel Quadra-Salcedo Gayarre.
   nombre=$(echo "$nombre" | sed -r 's:\b[a-z]\w* ?::g')

   [ -n "$nombre" ] || return 1

   set -- $nombre  # Descomponemos el nombre.

   inicial=$(printf "%.1s" "$1")  # Inicial del primer nombre.
   shift

   # Nos quedamos sólo con las dos últimas palabras (los apellidos)
   while [ $# -gt 2 ]; do
      shift
   done

   digitos=$(echo "$nif" | sed -r 's:.*([0-9]{3})[A-Z]?$:\1:')

   echo "$inicial$(printf "%.3s" "$@")$digitos" | tr '[:upper:]' '[:lower:]'
}


#
# Comprueba si la línea del fichero de entrada
# tiene el formato correcto.
# $1: Nombre
# $2: NIF
# $3: Curso del alumno
#
comprobar_linea() {
   # La línea no debe estar vacía ni ser de comentario
   [ -n "${1%%#*}" ] || return 1

   # NIF incorrecto (podría mejorarse y comprobrar la letra).
   echo "$2" | grep -qE '^[0-9]{7,8}[A-Z]$' || return 2

   case $3 in
      1|2|1+) ;;
      *) return 2 ;;
   esac

   return 0
}


#
# Analiza un usuario inscrito en la entrada y
# realiza la operación pertinente.
# $1: Nombre completo de alumno
# $2: NIF.
# $3: Grupo al que debe pertenecer el alumno
#
trata_usuario() {
   local nick princpal secundario

   exec 3>&1 1>&2

   nick=$(crea_nick "$1" "$2") || return 1

   case "$3" in
      1) principal="$GRUPO1" ;;
      2) principal="$GRUPO2" ;;
      1+)
         principal="$GRUPO1"
         secundario="$GRUPO2"
         ;;
   esac

   if id "$nick" >/dev/null 2>&1; then
      pone_grupo_principal "$nick" "$principal"
   else
      add_user "$nick" "$principal" "$(desacentua $nombre)"
   fi

   if [ -n "$secundario" ]; then 
      agrega_grupo_secundario "$nick" "$secundario"
      cambia_gecos "$nick" "$(desacentua "$1 (repetidor)")"
   fi

   exec 1>&3 3>&-

   echo "$nick"
}


{ ##  Manipulación de usuarios (cambiará si no son locales).
   #
   # Crea el usuario con contraseña nula y obliga
   # a cambiar la contraseña en el próximo login.
   #
   add_user() {
      adduser "$1" --ingroup "$2" --gecos "$3" --disabled-password
      usermod -p "" "$1"
      chage -d0 "$1"
   }


   pone_grupo_principal() {
      usermod -g "$2" "$1"
   }


   agrega_grupo_secundario() {
      adduser "$1" "$2"
   }


   del_user() {
      deluser --remove-home "$1"
   }


   cambia_gecos() {
      chfn -f "$2" "$1"
   }
}

#
# Borrar los antiguos alumnos que
# han dejado el instituto en el nuevo curso
# $@: Los nicks de todos los alumnos que sí están matriculados.
# 
borrar_antiguos() {
   local IFS="|" user grupo

   [ $# -gt 0 ] || return 0

   getent passwd | awk -F: '$1 !~ /('"$*"')/ {print $1}' | while read -r user; do
      case "$(id -gn "$user")" in
         $GRUPO1|$GRUPO2) 
            del_user "$user"
            ;;
      esac
   done
}

#
# MAIN
#

soy_root || error 1 "Necesita permisos de administración"
[ -f "$1" ] || error 1 "$1: Fichero inexistente"

for grupo in "$GRUPO1" "$GRUPO2"; do
   getent group "$grupo" >/dev/null || error 1 "El grupo $grupo no existe"
done


num=0
matriculados=
while IFS=: read -r nombre nif curso; do
   num=$((num+1))

   comprobar_linea "$nombre" "$nif" "$curso"
   case $? in
      0) ;;
      1) # Simnplemente es una línea en blanco o de comentario
         continue
         ;;
      2) error 0 "Línea $num incomprensible" >&2
         continue
         ;;
   esac

   nick=$(trata_usuario "$nombre" "$nif" "$curso") 
   if [ $? -ne 0 ]; then
      error 0 "No puede generarse nick para $nombre. Se salta"
      continue
   fi

   matriculados="$matriculados $nick"
done < "$1"

borrar_antiguos $matriculados
