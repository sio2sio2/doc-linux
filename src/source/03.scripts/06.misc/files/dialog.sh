# Definiciones para hacer más simple el uso de whiptail.
dialog() {
   local NEWT_COLORS
   if [ "$1" = "error" ]; then
      export NEWT_COLORS="root=,red roottext=yellow,red"
      shift
   fi

   # Aquí podemos añadir opciones comunes
   # a todos los whiptail del programa
   set -- --backtitle 'Cacharreo Free Software Labs' "$@"

   whiptail "$@" 3>&1 1>&2 2>&3
} 
alias edialog='\dialog error'

