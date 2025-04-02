#!/bin/sh
#
# Script para impedir que el usuario que accede al servidor SSH haga
# otra cosa distinta a cambiar la contraseña, acceder con sftp o usar scp.
#
# Admite como único parámetro el directorio de enjaulamiento. Si este
# no se facilita los usuarios no estarán enjaulados.
#

ANONIMO="ftp anonymous"
SFTPSERVER=/usr/lib/openssh/sftp-server

COMMAND="$(echo $SSH_ORIGINAL_COMMAND | awk '{print $1}')"

get_chrootdir() {
   [ -z "$1" ] || echo "$1" | sed -r 's:(^|[^%])%u:\1'$USER':; s:(^|[^%])%h:\1'$HOME':; s:(^|[^%])%n:\1'$(id -u)':; s:(^|[^%])%x:\1'$XDG_RUNTIME_DIR':'
}

chpasswd() {
   local PID=$$ oldpass pass1 pass2

   while [ -z "$oldpass" ]; do
      oldpass=$(whiptail --passwordbox "Contraseña actual:" 8 35 3>&1 1>&2 2>&3) || exit 1
   done

   while [ -z "$pass1" ];  do
      pass1=$(whiptail --passwordbox "Nueva Contraseña:" 8 35 3>&1 1>&2 2>&3) || exit 1
   done

   while true;  do
      pass2=$(whiptail --passwordbox "Repita la contraseña:" 8 30 3>&1 1>&2 2>&3) || exit 1
      [ "$pass1" = "$pass2" ] && break
      NEWT_COLORS="root=,red" whiptail --msgbox "ERROR. Ha introducido dos contraseñas distintas" 7 55
   done

   echo "$oldpass
$pass1
$pass1
" | passwd >/dev/null 2>&1
   if [ $? -eq 0 ]; then
      whiptail --msgbox "Nueva contraseña establecida" 7 45
   else
      NEWT_COLORS="root=,red" whiptail --msgbox "ERROR. La contraseña NO ha cambiado" 7 45
   fi
}

acceso_anonimo() {
   echo "$ANONIMO" | grep -qw "$USER"
}

echar() {
   echo "Usuario de FTP sin acceso al servidor"
   exit 255
}

case "$COMMAND" in
   scp|$SFTPSERVER)
      CHROOTDIR=$(get_chrootdir $1)
      if [ -n "$CHROOTDIR" ]; then
         if which fakechroot > /dev/null; then
	    #SSH_ORIGINAL_COMMAND="fakechroot chroot $CHROOTDIR sh -c \"cd $HOME; $SSH_ORIGINAL_COMMAND\""
	    SSH_ORIGINAL_COMMAND="fakechroot chroot $CHROOTDIR $SSH_ORIGINAL_COMMAND"
         else
            echo "No ha instalado fakechroot en el servidor y el enjaulamiento es imposible..." >&2
            exit 254
         fi
      fi
      eval exec "$SSH_ORIGINAL_COMMAND"
      ;;
   "")
      acceso_anonimo && echar
      chpasswd
      ;;
   *)
      echar
esac
