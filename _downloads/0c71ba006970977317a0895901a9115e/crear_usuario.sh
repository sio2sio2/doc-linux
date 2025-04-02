#!/bin/sh
#

GRUPO=losdelftp
UPLOADS=uploads
# Límite en MiB
LIM_NORMAL=1024
LIM_FTP=500


#
# Monkeypatch de read
# para soportar la opción -s
#
read() {
   local settings ret

   if [ "$1" = "-s" ]; then
      shift
      settings=$(stty -g)
      stty -echo
   fi

   command read "$@"
   ret=$?

   [ -n "$settings" ] && stty "$settings"
   return $ret
}


soy_root() {
   [ $(id -u) -eq 0 ] 
}


help() {
   echo "$(basename $0) [usuario] [contraseña]: Crea fácilmente usuarios para el servidor (s)FTP.
   El script permite crear usuarios de dos naturalezas:

   * Usuarios normales con acceso SSH habitual.
   * Usuarios exclusivos que sólo podrán acceder al servidor a través de sftp.

Ejemplos de uso:

1) Crea un usuario (pidiendo de forma interactiva usuario y contraseña):

   # crear_usuario.sh

   Cuando se pide interactivamente el usuario no debe anteponer el prefijo
   'f:' en ningún caso: el programa se encarga de preguntarle explícitamente
   la naturaleza del usuario.

2) Crea un usuario normal (y pide la contraseña de forma interactiva):

   # crear_usuario.sh usuario

   Para notar usuarios que son de FTP, debe anteponer el prefijo 'f:':

   # crear_usuario.sh f:usuario

3) Crear usuario pasando la contraseña.sh:

   # crear_usuario.sh usuario contraseña
   # crear_usuario.sh f:usuario contraseña
   # crear_usuario.sh usuario =

   En el último caso, la contraseña coincidirá con el nombre de usuario.

4) Pasar un lote de usuarios por la entrada estándar

   # crear_usuario.sh < usuarios.txt

   En este caso, el fichero tiene el siguiente formato:

     # Esto es una línea comentada (la siguiente está vacía y se ignora)

     usuario1  contraseña  # Usuario normal completamente definido
     f:usuario2            # La contraseña coincide con el nombre de usuario.
     f:usuario3  =         # Ídem.
     usuario4    ?         # La contraseña se pide interactivamente.
     # etc...

   Del fichero se obvian líneas en blanco o comentadas o finales
   de línea comentados.
"
}

#
# Pregunta si se desea que el usuario pueda acceder
# exclusivamente a través de FTP.
# return: 0, si sí es exlusivo.
#
es_usuario_ftp() {
   local resp

   while true; do
      read -p "¿Desea que el usuario sólo acceda por FTP (s/n)? " resp <&3
      case "$resp" in
         S|s) return 0 ;;
         N|n) return 1 ;;
         *) ;;
      esac
   done
}


#
# Pregunta el nombre de usuario y comprueba si este es válido.
# $1: Nombre de usuario. Si se proporciona no se pregunta.
# stdout: El nombre de usuario
#
preguntar_usuario() {
   local usuario="$1"

   [ -z "$usuario" ] && read -r -p "Escriba el nombre de usuario: " usuario <&3
   if ! es_valido "$usuario"; then
      echo "El nombre de usuario es incorrecto" >&2
      return 1
   elif existe "$usuario"; then
      echo "El usuario ya existe. Pruebe otro nombre" >&2
      return 1
   fi

   echo "$usuario"
}


#
# Comprueba si el nombre de usuario se ajusta a nuestras reglas de nombrado
# $1: El nombre de usuario
# return: 0, válido.
#
es_valido() {
   # El nombre debe estar en minúsculas y puede contener
   # letras, números y guiones y subrayados.
   expr "$1" : '[a-z_][a-z0-9_-]*' > /dev/null
}


#
# Comprueba si existe el usuario
# $1: El nombre de usuario.
# return: 0, existe.
#
existe() {
   id "$1" >/dev/null 2>&1
}


#
# Pregunta e imprime la contraseña de usuario.
#
preguntar_password() {
   local pass1 pass2

   while true; do
      read -s -r -p "Contraseña: " pass1 <&3
      echo >&4
      es_valido_password "$pass1" || { echo "Contraseña inválida" >&2; continue; }
      read -s -r -p "Repita la contraseña: " pass2 <&3
      echo >&4
      [ "$pass1" = "$pass2" ] && break
      echo "Las contraseñas no coinciden" >&2
   done
   echo "$pass1"
}


#
# Comprueba si la cotraseña se ajusta a las reglas que establezcamos
# $1: La contraseña.
# return: 0, si válida.
#
es_valido_password() {
   return 0
}


#
# Crea el usuario en el sistema
# $1: El nombre de usuario.
# $2: La contraseña
# $3: 0, si el usuario es de FTP solamente.
#
crear_usuario() {
   if [ $3 -eq 0 ]; then
      adduser --disable-password "$1" --gecos "$1"
      fijar_cuota "$1" $((LIM_NORMAL*1024))
   else
      adduser --disable-password --ingroup "$GRUPO" "$1" --gecos "$1"
      tunear_usu_ftp "$1"
      fijar_cuota "$1" $((LIM_FTP*1024))
   fi
   echo "$1:$2" | chpasswd
}


#
# Tunear al usuario de FTP
# $1: El nombre de usuario
#
tunear_usu_ftp() {
   adduser "$1" "$GRUPO"
   getent passwd "$1" | {
      IFS=: read _ _ _ gid _ home _
      chown root:root "$home"
      mkdir "$home/$UPLOADS"
      chown "$1:$gid" "$home/$UPLOADS"
   }
}


#
# Imprime el sistema de fichero al que
# pertenece el directorio personal de un usuario
# $1: Nombre del usuario
#
obtener_fs() {
   local home=$(getent passwd "$1" | cut -d: -f6)
   stat "$home" --printf=%m
}


#
# Fija la cuota del usuario
# $1: El nombre de usuario.
# $2: Cuota en bloques de 1K
#
fijar_cuota() {
   local limite=$2 fs="$(obtener_fs "$1")"
   if quota -f "$fs" > /dev/null; then
      setquota -u "$1" "$limite" "$limite" 0 0 "$fs"
   else
      echo "No se han configurado las cuotas para $fs" >&2
      return 1
   fi
}


#
# Elimina del fichero de entrada que contiene los
# usuarios y contraseñas, la información insustancial
# (líneas en blanco, comentarios, etc.).
#
filtrar_entrada() {
   sed -re '
      s/\s*#.*$//
      /^\s*$/d
   '
}


[ "$1" = "-h" ] && help && exit 0


if ! soy_root; then
   echo "Este script necesita permisos de administración" >&2
   exit 1
fi

if [ -t 0 ]; then   # No se pasa fichero (los argumentos son la entrada)
   exec 3<&0 0<<EOF
${1:-?} ${2:-?}
EOF
fi

exec 4>&1  # Almacenamos en 4 la salida estándar.

filtrar_entrada | while command read -r usuario password; do
   if [ "$usuario" = "?" ]; then
      until usuario=$(preguntar_usuario); do
         echo "Vuelva a intentarlo, por favor"
      done
      es_usuario_ftp
   else
      preguntar_usuario "${usuario#f:}" > /dev/null || continue
      [ -z "${usuario%f:*}" ] && usuario=${usuario#f:}
   fi
   ftp=$?
   case "$password" in
      "?"|"") password=$(preguntar_password) ;;
      =)      password=$usuario ;;
   esac
   crear_usuario "$usuario" "$password" "$ftp"
done
