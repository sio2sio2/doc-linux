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
