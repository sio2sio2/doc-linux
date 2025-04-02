#!/bin/sh

LIM=90
TYPE="ext4"
ADDR="root@localhost"


help() {
   echo "$(basename $0) [opciones]:
   Comprueba qué sistemas de ficheros superan un umbral máximo de ocupación.

Opciones:

 -f, --filesystem /ruta    Sistema de ficheros al que pertenece la ruta, del
                           que se quiere comprobar la ocupación. Si se desea
                           comprobar varios, puede repetirse la opción. No
                           tiene efecto si se usa también -t.
 -h, --help                Muestra esta misma ayuda.
 -l, --limit N             Umbral máximo en %. Si no se especifica, el 90%.
 -m, --mail direccion      Dirección de correo a la que enviar el aviso, en
                           caso de que algún sistema de ficheros supere el
                           umbral máximo. Por defecto, root@localhost.
 -s,--stdout               En vez de enviar un mensaje de correo, muestra
                           el mensaje por pantalla.
 -t, --type tipo           Tipo de los sistemas de ficheros cuya ocupación se
                           coomprobará. Si se desea comprobar la ocupación de
                           distintos tipos, puede repetirse la opción. Si no
                           se especifica ni tamnpoco -f, se sobreentiende
                           ext4.
"
}


#
# Imprime un mensaje de error y acaba el programa
# $1: Código de salida.
# $2: Mensaje de error.
#
error() {
   local exitcode=$1
   shift

   echo "$*"
   exit $exitcode
}


#
# Determina las puntos de montaje a los que pertenecen
# las rutas suministradas. Si la ruta no existe, se elimina.
# Los puntos de montaje repetidos, se eliminan también.
#
get_mountpoint() {
   local IFS='
'
   for path in $*; do
      if [ ! -e "$path" ]; then
         echo "No existe $path: se descarta." >&2
         continue
      fi
      findmnt -nT "$path" -o TARGET
   done | sort | uniq 
}


#
# Obtiene la ocupación de los sistemas de ficheros, y
# devuelve sólo los sistemas que llegan al máximo tolerable.
#
extrae_ocupacion() {
   local a b

   if [ -n "$type" ]; then
      findmnt -t "$type" -nlo TARGET,USE%
   else
      echo "$fs" | while read -r fstype; do
         findmnt -T "$fstype" -nlo TARGET,USE%
      done
   fi | awk '($2=int(substr($2, 0, length($2)))) >= '"$limit"' {print $1, $2}'
}


#
# Genera la línea de salida para cada sistema de ficheros.
#
# Por ejemplo:
#   echo "/home 90" | formatea_salida
# devuelve
#   /home................90%
#
formatea_salida() {
   cat | while read line; do
      printf "%-20s %3d%%\n" $line | tr " " "."
   done
}


#
# Envía un mensaje de correo.
# $1: Texto del mensaje
#
send_mail() {
   echo "From: root@localhost
To: $mail
Subject: ALERTA!!!! Disco casi lleno.

$1" | sendmail -t
}


#
### Argumentos.
#
{
   fs=
   limit=$LIM
   mail=$ADDR
   while [ $# -gt 0 ]; do
      case $1 in
         -f|--filesystem)
            fs="$fs
   $2"
            shift 2
            ;;
         -l|--limit)
            limit=$2
            shift 2
            ;;
         -h|--help)
            help
            exit 0
            ;;
         -m|--mail)
            mail=${mail:+$2}
            shift 2
            ;;
         -s|--stdout)
            mail=
            shift
            ;;
         -t|--type)
            type="$type -t $2"
            ;;
         -*) error 2 "-$1: Opción desconocida"
      esac
   done

   fs=$(get_mountpoint "$fs")

   if [ -n "$type" ]; then
      fs=""
   elif [ -z "$fs" ]; then
      type="$TYPE"
   fi
}


if [ "$mail" ] && ! which sendmail >/dev/null; then
   error 1 "Falta el ejecutable sendmail. Use -s si quiere imprimir por pantalla" 
fi

mensaje=$(extrae_ocupacion | formatea_salida)

[ -n "$mensaje" ] || exit 1

mensaje="El sistema ha detectado que los siguientes volumenes
han superado el ${limit}% de uso:

$mensaje

Se le recomienda que los aumente o elimine informacion de ellos."

[ -n "$mail" ] && send_mail "$mensaje" || echo "$mensaje"
