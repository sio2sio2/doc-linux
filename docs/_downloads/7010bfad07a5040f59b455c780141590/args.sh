#!/bin/sh

help() {
   echo "$(basename $0): Ilustra el procesamiento de las opciones de un script.

Opciones:
 -h, --help                      Muestra esta misma ayuda.
 -f, --file <FICHERO>            Fichero de entrada...
 -p, --password <PASSWORD>       Permite indicar la contraseña.
 -v, --verbose                   Ofrece más información.
"
}


#
# Parche para que una opción no sea considerada
# argumento de la opción precedente, cuando esta
# precisa un argumento.
#
patch_dash() {
   [ "$opt" = ":" -o "$opt" = "?" ] && return 0
   if echo $OPTARG | grep -q '^-'; then
      OPTARG=$opt
      opt=":"
   fi
}


#
# Parche para soportar opciones largas.
#
patch_lo() {
   local LO="$1" _OPT="$2"
   shift 2

   eval "[ \$$_OPT = '-' ] || return 0"

   local o=${OPTARG%%=*}
   eval $_OPT=\$o

   if ! echo "$LO" | grep -qw "$o"; then  # La opción no existe
      eval $_OPT='\?'
      OPTARG=-$o
      return 1
   fi

   OPTARG=$(echo "$OPTARG" | cut -s -d= -f2-)  # Suponiendo --opcion=valor
   if echo "$LO" | grep -q "\<$o:"; then  # La opción requiere argumento
      if [ -z "$OPTARG" ]; then  # Se debió escribir --opcion valor
         eval OPTARG=\$$((OPTIND))
         if [ -z "$OPTARG" ]; then  # No se facilitó argumento
            eval $_OPT=":"
            OPTARG=-$o
            return 1
         fi
         OPTIND=$((OPTIND+1))
      fi
   elif [ -n "$OPTARG" ]; then  # No requiere argumento, pero se ha añadido uno.
      # Se elimina el argumento
      OPTARG=""
   fi
}


#
# Parche para soportar opciones con argumento opcional.
#
patch_optarg() {
   local OPTS="$1" _OPT="$2"
   eval local o=\$$_OPT

   # La opción estaba a final de línea.
   [ "$o" = ":" ] && oo="${OPTARG#-}" || oo="$o"

   echo "$OPTS" | grep -qE '\b'"$oo"'\b' || return 0
   # Si falló por no haber más argumentos,
   # corregimos para que el argumento sea nulo
   if [ "$o" = ":" ]; then
      eval $_OPT='$OPTARG'
      OPTARG=
   # Si el argumento es la siguiente opción,
   # retrocedemos en la lectura y hacemos nulo el argumento.
   elif [ -z "${OPTARG%%-*}" ]; then
      OPTIND=$((OPTIND-1))
      OPTARG=
   fi
}


# Un error de sintaxis, muestra siempre la ayuda.
trap '[ $? -eq 2 ] && help' EXIT

#
### Tratamiento de argumentos.
#

while getopts ":hvf:p:-:" opt; do
   patch_lo "help verbose file:password:" opt "$@"
   patch_optarg "p password" opt
   patch_dash
   case $opt in
      h|help)
         help
         exit 0
         ;;
      \?)
         echo "-$OPTARG: Opción inválida."
         exit 2
         ;;
      :)
         echo "-$OPTARG requiere un argumento"
         exit 2
         ;;
      f|file)
         FICHERO=$OPTARG
         ;;
      p|password)
         PASSWORD=$OPTARG
         ;;
      v|verbose)
         VERBOSE=1
         ;;
   esac
done
shift $((OPTIND-1))

# Fin del tratamiento

echo "RESULTADOS"
echo "FICHERO=$FICHERO"
echo "PASSWORD=$PASSWORD"
echo "VERBOSE=$VERBOSE"
echo "$@"
