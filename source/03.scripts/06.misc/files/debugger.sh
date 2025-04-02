# debugger.sh: funciones para depuración de código
debug() {
   [ $__untrap -eq 1 ] && return 
   echo "Línea $1: $BASH_COMMAND"
   while true; do
      read -p "> " comm
      [ -z "$comm" ] || [ "$comm" = "n" ] && return
      [ "$comm" = "c" ] && __untrap=1 && return
      eval $comm
   done
}

breakpoint() {
   __untrap=0
   trap 'debug $LINENO' DEBUG
}

continue {
   trap '' DEBUG
}
