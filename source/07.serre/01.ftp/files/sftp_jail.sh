#!//bin/sh
#
# Prepara una jaula personal cada usuario de FTP.
# Argumentos:
#   group=XXX[,YYY[,ZZZ...]]   Grupos de FTP.
#   dir=DDD                    Directorio personal del usuario
#   jail=EEE                   Directorio con la base de la jaula
#   mountpoint=FFF             Punto de montaje para la jaula
#
# La jaula resultante es la fusión de dir y jail y aparece
# en mountpoint.

DEFAULT_GROUP=ftpusers
DEFAULT_FTPDIR=/srv/ftp/%u
DEFAULT_MOUNTPOINT=%x/ftp
DEFAULT_BASEJAIL=/var/lib/sftp_jail

[ "$PAM_SERVICE" = "sshd" ] || exit 0

# Obtención de los argumentos
while [ $? -gt 0 ]; do
   eval $1
   shift
done
[ -n "$dir" ] || dir=$DEFAULT_FTPDIR
[ -n "$jail" ] || jail=$DEFAULT_BASEJAIL
[ -n "$mountpoint" ] || mountpoint="$DEFAULT_MOUNTPOINT"

# Obtiene un directorio deshaciendo %u, %h, etc.
get_dir() {
   local HOME=$(getent passwd "$PAM_USER" | cut -f6 -d:)
   echo "$1" | sed -r 's:(^|[^%])%u:\1'$PAM_USER':; s:(^|[^%])%h:\1'$HOME':; s:(^|[^%])%n:\1'$(id -u)':; s:(^|[^%])%x:\1'$XDG_RUNTIME_DIR':'
}

dir=$(get_dir "$dir")
mountpoint=$(get_dir "$mountpoint")

# Comprueba si el usuario es del grupo
# de usuarios que acceden solo por FTP
check_group() {
   if [ -n "$group" ]; then
      #Puede contener varios grupos separados por comas.
      group=$(echo $group | tr ',' '|')
   else
      group="$DEFAULT_GROUP"
   fi

   id -nG "$PAM_USER" | egrep -wq "$group"
}

# Número de sesiones abiertas con sshd
# En open_session no cuenta la que se abre, pero
# en close_sesssion sí cuenta la que se cierra.
get_num_sessions() {
   pgrep -c -u "$PAM_USER" sshd
}

# Prepara la jaula
crear_jaula() {
   check_group || exit 0
   [ $(get_num_sessions) -eq 0 ]  || exit 0
   local WORKDIR=$(dirname $dir)"/.$PAM_USER"
   if [ ! -d "$dir" ]; then
      echo "$dir no existe"
      exit 1
   fi

   mkdir -p "$WORKDIR" "$mountpoint"
   mount -t overlay overlay -o "lowerdir=$jail,upperdir=$dir,workdir=$WORKDIR" "$mountpoint"
   mount | grep "$mountpoint"
   [ -h  "$mountpoint"/etc/passwd ] && rm -f "$mountpoint"/etc/passwd
   getent passwd $PAM_USER > "$mountpoint"/etc/passwd
}

# Deshace la jaula
destruir_jaula() {
   check_group || exit 0
   [ $(get_num_sessions) -eq 1 ] || exit 0

   local WORKDIR=$(dirname $dir)"/.$PAM_USER"

   umount $mountpoint
   rmdir "$WORKDIR/work" "$WORKDIR" "$mountpoint"
   rm -rf "$dir"/etc
}

case "$PAM_TYPE" in
   open_session)
      crear_jaula
      ls -l $mountpoint
      ls -l $mountpoint/etc
      cat $mountpoint/etc/passwd
      ;;
   close_session)
      destruir_jaula
      exit 0
      ;;
   *)
      echo "Script sólo aplicable a session"
      exit 255
esac
