get_shell() {
   # local no funciona en ksh, así que la probamos por separado.
   [ -n "$KSH_VERSION" ] && [ -z "${KSH_VERSION##*Version AJM*}" ] && echo "ksh"

   # La implementación de ps que hace busybox no tiene opción -p.
   local exec="$(ps -p $$ -o command= 2>/dev/null | sed 's:^-\?\([^ ]\+\).*:\1:' || echo "busybox")"
   local shell=$(which "$exec")
   basename $(readlink -e "${shell:-$exec}")
}
