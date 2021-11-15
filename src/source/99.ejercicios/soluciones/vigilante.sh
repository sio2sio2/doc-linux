#!/bin/sh

REPORTDIR="${REPORTDIR:-$HOME/informes}"


help() {
   echo "$(basename "$0") -h|-c usuario|-g grupo
   Recoge los script realizados por los usuarios de un grupo
   y comprueba si los ha modificado con posterioridad.

Opciones:

 -c USUARIO    Usuario del que se quieren comprobar los scripts.
 -f            Fuerza a crear al informe, aunque ya exista uno con
               ese nombre.
 -g GRUPO      Grupo principal de los usuarios de los que se quiere
               recoger los scripts. No tiene por qué ser el principal.
 -h help       Mensaje de ayuta.
 -s NUM        Cambia el informe que se toma como referencia. Si NUM
               es 0, se usa el último informe; si NUM es 1, el penúltimo,
               y así sucesivamente.
"
}


#
# Trata los errores
#
error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      log ERROR "$@"
   else
      log CRIT "$@"
      exit "$EXITCODE"
   fi
}


#
# Logs
#
DEBUG=7; INFO=6; NOTICE=5; WARN=4; ERROR=3; CRIT=2
log() {
   eval local etiqueta="$1" level=\$"$1" salida mensaje 
   shift
   mensaje="[$etiqueta] "$*
   salida="${LOGERR:+--no-act -s}"
   
   [ "$level" -le "$CRIT" ] && salida=${salida:-"-s"}

   [ "${LOGLEVEL:-$WARN}" -ge "$level" ] || return 0

   set -- "-p$level" $salida "--id=$$" "$mensaje"
   logger "$@"
}


#
# En una tubería simple de dos meimbros devuelve
# el código de salida de la orden izquierda.
#
pf() {
   local XC run

   while [ $# -gt 0 ]; do
      if [ "$1" = "|" ]; then
         run="$run "'3>&- 4>&-; echo $? >&3; } '
         break
      else
         run="$run '$1'"
      fi
      shift
   done

   eval "{ { { " $run "$@" '>&4; } 3>&1 | { read XC; return $XC; } } 4>&1'
}


soy_root() {
   [ "$(id -u)" -eq 0 ]
}


#
# Obtiene el GID de un grupo.
# $1: Nombre del grupo.
#
gid_grupo() {
   getent group "$1" | cut -d: -f3
}


#
# Comprueba la existencia de un usuario
# $1: Nombre del usuario
#
existe_usuario() {
   getent passwd "$1" >/dev/null
}


#
# Obtiene el grupo primario al que pertenece un usuario
#
grupo_primario() {
   id  -gn "$1"
}

#
# Lista los usuarios que pertenecen cuyo principal es el facilitado.
# $1: El grupo.
#
# Devuelve una lista de usuarios en que cada línea es de la forma:
#
#    USUARIO:HOME_DEL_USUARIO
#
lista_usuarios() {
   local user IFS GRUPO="$(gid_grupo "$1")"

   [ -n "$GRUPO" ] || return 1

   log DEBUG "Generando la lista de usuarios cuyo grupo primario es '$GRUPO'"

   getent passwd | awk -F: '$4 == "'"$GRUPO"'" {print $1 ":" $6}'
}


#
# Comprueba si un fichero es un script.
# $1: El nombre del script.
#
script_test() {
   [ $(file --mime-type -b "$1") = "text/x-shellscript" ]
}


#
# Lista los scripts de la shell contenidos contenidos bajo un determinado
# directorio que son más recientes que un fichero de referencia.
# $1: Usuario al que pertenecen los script.
# $1: El directorio.
# $2: La referencia. Puede no existir.
#
lista_ficheros() {
   local REF="${3:+"-newer '$3'"}"

   # Argumentos de find (hacemos así para solucionar el problema
   # de los nombres de ficheros que contienen espacios.
   eval set -- "'$2'" -type f -user "'$1'" $REF

   log INFO "Obteniendo la lista de scripts del usuario '$1'."

   find "$@" | while read -r file; do
      if script_test "$file"; then
         echo "$file"
         log DEBUG "Hallado script con nombre '$file'."
      else
         log DEBUG "Se descarta por no ser script el fichero '$file'."
      fi
   done
}


#
# Obtiene el informe de referencia
# $1: Grupo al que pertenece el informe.
# $2: Ordinal: 0, último informe; 1: penúltimo informe, etc.
#
obtiene_referencia() {
   [ -d "$REPORTDIR" ] || return 1

   command ls -tr "$REPORTDIR/$1"_[0-9]*.txt 2> /dev/null | tail -n+$((${2:-0}+1)) | head -n1
}


#
# Prepara el fichero para el informe antes de generarlo.
# $1: Nombre del informe (con ruta)
# $2: Cualquier valor indica que se debe forzar la escritura del informe,
#     aunque ya existiera uno con el mismo nombre.
#
prepara_informe() {
   mkdir -p "$(dirname "$1")"
   [ ! -f "$1" ] || { [ -n "$FORCE" ] && rm -f "$1"; }
}


#
# Genera el contenido del informe (1a tarea).
# $1: Nombre del grupo
# $2: Referencia (ordinal)
#
# El informe tiene el siguiente formato:
#
#  %
#  usuario1
#  /path/absoluto/script1=MD5
#  /path/absoluto/script2=MD5
#  etc...
#  %
#  usuario2
#  /path/absoluto/script1=MD5
#  etc...
#
genera_informe() {
   local IFS referencia="$(obtiene_referencia "$2")"

   if [ -n "$referencia" ]; then 
      log DEBUG "Se toma como referencia el informe previo '$referencia'"
   else
      log DEBUG "No hay referencia previa para crear el informe"
   fi
   
   log INFO "Generando el informe '$informe' para el grupo '$GRUPO'"

   lista_usuarios "$1" | while IFS=: read -r usuario home; do
      echo "%"
      echo "$usuario"
      lista_ficheros "$usuario" "$home" "$referencia" | tr '\n' '\0000' | xargs -0 -r md5sum | awk '{print $2 "=" $1}'
   done
}


#
# Obtiene los scripts que pertenecen a un usuario
# $1: Nombre del informe
# $2: Nombre del usuario
#
# La salida son líneas de la forma:
# 
#    NOMBRE=MD5
#
lista_scripts() {
   awk -v RS="\n?%\n" -v U="$2" '$1 == U {print $0; exit 0}' "$1" | tail -n+2
}


#
# Comprueba los scripts de un usuario
# $1: Nombre del usuario
#
# Devuelve:
#  0: Si acabó con exito.
#  1: Si hay algún script modificado.
#  2: Si no hay informe.
#
comprueba_scripts() {
   local USUARIO="$1"
   local GRUPO="$(grupo_primario "$USUARIO")"
   local INFORME="$(obtiene_referencia "$GRUPO" "$2")"

   [ -n "$INFORME" ] || return 2

   log INFO "Comprobando los scripts de usuario '$USUARIO' que lista '$INFORME'."

   lista_scripts "$INFORME" "$USUARIO" | while IFS="=" read -r script checksum; do
      [ -n "$script" ] || return 3
      printf "%s:" "$script"
      if [ ! -f "$script" ]; then
         echo "Borrado"
      elif echo "$checksum $script" | md5sum --status -c; then
         echo "Correcto"
      else
         echo "Modificado"
         return 1
      fi
   done
}


#
# Formatea el resultado de la comprabación de los scripts.
#
formatea() {
   local home="$(getent passwd "$1" | cut -d: -f6)"

   while IFS=: read -r script estado; do
      script="~${script#$home}"  # Ponemos ~, en vez de la ruta explícita.
      printf "%.65s %s\n" "$script...................................................................................." "$estado"
   done
}


#
# Comprueba si el argumento suministrado es posicional o una opción
#
check_arg() {
   [ -n "${1%%-*}" ]
}


######## MAIN ########

#
### Argumentos  
#
{
   REF=0
   while [ $# -gt 0 ]; do
      case $1 in
         -h|--help)
            help
            exit 0
            ;;
         -c|--usuario)
            check_arg "$2" || error 2 "$1 requiere un argumento."
            USUARIO="$2"
            existe_usuario "$USUARIO" || error 1 "Usuario '$USUARIO' inexistente"
            shift
            ;;
         -f|--force)
            FORCE=1
            log DEBUG "Se fuerza la sobreescritura de informes"
            ;;
         -g|--grupo)
            check_arg "$2" || error 2 "$1 requiere un argumento."
            GRUPO="$2"
            [ -n "$(gid_grupo "$2")" ] || error 1 "Grupo '$GRUPO' inexistente"
       shift
            ;;
         -s)
            check_arg "$2"
            REF=$2
            echo "$2" | grep -Eq '^[0-9]+$' || error 1 "$1 exige un número natural o cero"
            shift
            ;;
         *)
            error 2 "$1: Opción inexistente"
            ;;
      esac
      shift
   done
}


if [ -n "$GRUPO" ]; then
   [ -z "$USUARIO" ] || error 2 "-c y -g son opciones excluyentes"
   soy_root || error 1 "Sólo root puede generar el informe"

   informe="$REPORTDIR/${GRUPO}_$(date -I).txt"

   prepara_informe "$informe" "$FORCE" || error 1 "'$informe' ya existe. Use -f para sobreescribir."
   genera_informe "$GRUPO" "$REF" > "$informe"
else
   [ "$(id -u)" -eq $(id -u "$USUARIO") ] || error 1 "Como usuario normal, sólo puede comprobar sus propios scripts"

   pf comprueba_scripts "$USUARIO" "$REF" \| formatea "$USUARIO"
   
   case $? in
      0) ;;
      1) echo
         error 3 "El alumno '$USUARIO' ha intentado hacer trampas." ;;
      2) error 1 "No hay informe" ;;
      3) echo "El alumno '$USUARIO' no ha hecho ningún script." ;;
   esac
fi
