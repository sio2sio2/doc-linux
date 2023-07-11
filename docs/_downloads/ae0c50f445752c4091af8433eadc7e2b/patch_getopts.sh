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
