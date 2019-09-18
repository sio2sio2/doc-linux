#
# Permite acomular acciones a señales y eventos.
# Uso:
#   trapplus "accion a realizar" SEÑAL1 [SEÑAL2... ]
#
# Las señales deben indicarse con su nombre, no su número.
#
trapplus() {
   local ACTION="$1" pre
   shift

   tmpfile=$(mktemp -u)

   for signal in "$@"; do
      # Para que funcione con dash (que incumple POSIX), hay que montar este sindios.
      { trap ; pre=$(awk '$NF ~ /^(SIG)?'"$signal"'$/ { $NF=""; print }'); rm -f "$tmpfile"; } > "$tmpfile" < "$tmpfile"
      if [ -n "$pre" ]; then
         eval "${pre%\' }; $ACTION' $signal"
      else
         trap -- "$ACTION" "$signal"
      fi
   done
}
