#!/bin/sh
#

REFERENCIA=${REFERENCIA:-$HOME/.REFERENCIA}
TARGETDIR="${TARGETDIR:-/tmp}"
LIMITE=${LIMITE:-150}

INDISPENSABLES='
   "/etc/network/interfaces"
   "/etc/resolv.conf"
'

EXCLUIDOS='
   "/dev"
   "/sys"
   "/proc"
   "/tmp"
   "/run"
   "/var/run"
   "/var/cache/apt"
   "/var/lib/apt"
   "/asgsag asasas/h ashsaas"
'

help() {
   echo "$(basename "$0") [opciones] [nombre]
   Realiza una copia de seguridad de los cambios realizados en el sistema
   después de una determinada referencia. El nombre de la copia será de la
   forma backup_nombre_AAAA-MM-DD.tar.xz, donde la fecha es la fecha en la
   que se ejecuta la orden y 'nombre' el proporcionado a través de la línea
   de órdenes. Si no se proporciona ninguno, se toma el nombre de la
   máquina (/etc/hostname) siempre que este nombre sea más reciente que la
   referencia.

Opciones:

 -d, --destination <DIR>   Directorio en que se almacenará la copia. Por
                           defecto, /tmp.
 -h, --help                Muestra esta misma ayuda.
 -e, --exception <FICHERO> Fichero que se incluirá en la copia en cualquier
                           caso, aunque sea más antiguo que la referencia o
                           quede fuera del límite temporal. Puede repetirse
                           la opción para incluir varios. Se incluyen por
                           defecto '/etc/network/interfaces' y
                           '/etc/resolv.conf', pero puede evitarse su copia
                           añadiendo -e '' en la línea de órdenes.
 -E, --exclude <DIR>       Directorio excluido de la copia. Repita la opción
                           si quiere excluir varios. Hay una lista
                           predeterminada  de directorios excluidos que puede
                           resetearse si se añade la opción -E ''.
 -f, --force               Fuerza a realizar la copia, aunque no se haya
                           cambiado el nombre de máquina.
 -l, --limit <N>           Tiempo en minutos antes del cual no se consideran
                           relevantes los cambios. Por defecto, 150 minutos
                           (3 horas). 0 implica que no hay limitación.
 -r, --reference <FICHERO> Fichero que se toma como referencia. Por defecto,
                           /root/.REFERENCIA. Si se usa como fichero el
                           guión (-), no existirá referencia.
 -u, --update              Actualiza la referencia al momento en que se
                           ejecuta el programa.
"
}


soy_root() {
   [ "$(id -u)" -eq 0 ]
}


error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "¡Atención! "$* >&2
   else
      echo "ERROR. "$* >&2
      exit $EXITCODE
   fi
}


join() {
   local glue="$1"
   shift

   printf -- "$1"
   shift
   [ $# -gt 0 ] && printf -- "$glue%s" "$@"
}


es_entero() {
   expr "$1" : '^[0-9]\+$' > /dev/null
}


# Comprueba si el primer fichero es más reciente que el segundo.
mas_reciente() {
   [ $((`stat --print "%Z-" "$1" "$2"; echo "0>0"`)) -eq 1 ]
}


# Obtiene el nombre completo que debe asignarse
# a la copia de seguridad
# $1: El directorio de destino
# $2: El nombre sugerido.
get_name() {
   local dirname="$1" name="$2"

   if [ -z "$name" ]; then
      if [ -n "$REFERENCIA" ] && [ -z "$FORCE" ] && mas_reciente "$REFERENCIA" "/etc/hostname"; then
         echo "El nombre en /etc/hostname es más antiguo que la referencia. Cámbielo o use --force"
         exit 1
      fi
      name=$(hostname)
   fi

   echo "$dirname/backup_${name}_$(date -I).tar.xz"
}


get_uuid() {
   cat /proc/sys/kernel/random/uuid 
}


#
# Obtiene los ficheros que deben incluirse en la copia
# $1: Los directorios excluidos de la copia
# $*: Las condiciones de filtro.
#
get_files() {
   local excl
   [ -n "${1%% }" ] && excl="-path '$(eval join "\"' -o -path '\"" $1)' -o"
   shift

   eval set -- '/ \(' $excl '-name "*.pyc" \)' -prune -o $* -print
   find "$@"
}


{ # Tratamiento de argumentos.
   EXTRA=
   EEXTRA=
   while [ $# -gt 0 ]; do
      case "$1" in
         -d|--destination)
            shift
            [ -d "$1" ] || error 1 "El directorio de destino '$1' no existe"
            TARGETDIR="$1"
            ;;
         -h|--help)
            help
            exit 0
            ;;
         -e|--exception)
            shift
            if [ -f "$1" ]; then
               EXTRA="$EXTRA"' "'"$1"'"'
            elif [ -z "$1" ]; then
               INDISPENSABLES=
            else
               error 0 "El fichero '$1' no existe"
            fi
            ;;
         -E|--exclude)
            shift
            if [ -e "$1" ]; then
               EEXTRA="$EEXTRA"' "'"$1"'"'
            elif [ -z "$1" ]; then
               EXCLUIDOS=
            else
               error 0 "El fichero o directorio '$1' no existe"
            fi
            ;;
         -f|--force)
            FORCE=1
            ;;
         -l|--limit)
            shift
            es_entero "$1" || error 1 "$1: No es un entero"
            LIMITE=$1
            ;;
         -r|--reference)
            shift
            if [ "$1" = "-" ]; then
               REFERENCIA=
            elif [ ! -f "$1" ]; then
               error 1 "$1: Referencia inexistente"
            else
               REFERENCIA="$1"
            fi
            ;;
         -u|--update)
            UPDATE=1
            ;;
         --)
            shift
            break
            ;;
         -*)
            error 2 "$1: Opción desconocida"
            ;;
         *) break
            ;;
      esac
      shift
   done

   [ $# -gt 1 ] && error 2 "Demasiados argumentos"
   TARGETNAME="$1"

   INDISPENSABLES="$INDISPENSABLES $EXTRA"
   EXCLUIDOS="$EXCLUIDOS $EEXTRA"
}


soy_root || error 1 "Se requieren permisos de administración"

if [ -n "$UPDATE" ]; then 
   touch -m "${REFERENCIA}"
   echo "Actualizada la referencia $REFERENCIA"
   exit 0
fi

[ $LIMITE -eq 0 ] || FILTER="-cmin -$LIMITE"

# Si hay fichero de referencia, los ficheros
# copiados, además, deben ser más recientes que él.
[ -f "${REFERENCIA}" ] && FILTER="$FILTER -cnewer '${REFERENCIA}'"

# Si no hay ni fichero de referencia ni límite temporal
[ -n "$FILTER" ] || error 1 "Sin referencia ni límite temporales"

# Actualizamos la fecha de los indispensables para que se haga copia de ellos
eval touch -ca $INDISPENSABLES

name=$(get_name "$TARGETDIR" "$TARGETNAME") || error 1 "$name"

[ -f ~/.uuid ] || get_uuid > ~/.uuid && touch ~/.uuid

get_files "$EXCLUIDOS" $FILTER | tar -P --no-recursion -acvf "$name" -T -
EXITCODE=$?

echo
if [ $EXITCODE -ne 0 ]; then
   error $EXITCODE "La copia para restauración ha fallado."
else
   echo "Copia para restauración almacenada como $name".
fi
