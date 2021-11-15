#!/bin/sh

LIST="${DISCOVER_LIST:-`dirname "$0"`/macs.txt}"
MAIL="${DISCOVER_MAIL:-root@localhost}"


help() {
   echo "$(basename "$0") [opciones]
   Descubre máquinas conectadas a la red.

Opciones:

 -h, --help                   Muestra esta misma ayuda.
 -i, --interface <IFACE>      Interfaz por la que se descubrirán máquinas. Si
                              no se especifica se sobreentenderán todas las que
                              posean una sireccion IP. Puede repertirse la opción
                              para realizar la búsqueda a través de varias
                              interfaces.
 -l, --list <FICHERO>         Lista de máquinas conocidas de la red.
 -m, --mail <EMAIL>           Dirección a la que enviará el correo.
 -o, --check-on               Comprueba qué máquinas que deberían estar apagadas,
                              se han quedado encendidas.
 -O, --check-off              Comprueba qué máquinas que deberían estar encendidas,
                              se han apagado.
-s, --stdout                  Muestra el mensaje por pantalla.
 
 Cada ítem de la lista de máquina conocidas tiene este formato:

 MAC       [-]Descripción

donde 'MAC' es la dirección MAC de la tarjeta y la descripción puede o no ir
antecedida por un signo -. El signo indica que la máquina se espera que esté
siempre encendida.
"
}


#
# Tratamiento de errores
#
error() {
   local EXITCODE=$1
   shift

   if [ "$EXITCODE" -eq 0 ]; then
      echo "¡Atención! "$* >&2
   else
      echo "ERROR. "$* >&2
      exit "$EXITCODE"
   fi
}


soy_root() {
   [ "$(id -u)" -eq 0 ]
}


#
# Comprueba que el argumento suministrado existe y
# es un argumento, no una opción.
#
check_arg() {
   [ -n "${1%%-*}" ]
}


#
# Comprueba si en la frase suministrada se encuentra el patrón
# suministrado como prier argumento.
# Si se pasa como segundo argumento "-s", la frase completa debe coincidir
# estrictamente con el patrón.
# La frase se puede pasar como argumento o por entrada estándar.
#
es_dir() {
   local pattern="$1"
   shift

   if [ "$1" = "-s" ]; then
      pattern="^$pattern\$" 
      shift
   fi

   if [ -n "$1" ]; then
      echo "$1" | grep -Eo "$pattern"
   else
      grep -Eo  "$pattern"
   fi
}


#
# Usa es_dir para determinar si se pasa una dirección MAC.
#
es_mac() {
   es_dir '\b(?[0-9A-F]{2}:){5}[0-9A-F]{2}\b' "$@"
}


#
# Usa es_dir para determinar si se pasa una dirección IP.
#
es_ip() {
   es_dir '\b(?[0-9]{1,3}\.){3}[0-9]{1,3}\b' "$@"
}


#
# Obtiene las interfaces con IPv4 asignada (excepto la de loopback).
# $@: Las interfaces que se quiere comprobar que existen y tienen IPv4.
#     Si no se incluye ninguna, se obtienen todas excepto lo.
#
get_ifaces() {
   local IFS="|"
   local cond='$2 != "lo"'

   [ $# -gt 0 ] && cond='$2 ~ '"/($*)/"

   ip -o -4 addr show | awk "$cond"' {print $2}'
}


#
# Filtra la salida de arp-scan para obtener sólo las líneas
# que representan máquinas.
#
filtro_arp() {
   stdbuf -o0 awk '$0 ~ /^[0-9]+\./ {print $2, $1}' | filtro_macs
}


#
# Busca las MACs proporcionadas en la lista de máquinas conocidas.
# Si se encuentra la MAC añade la descripción, y si no deja la
# entrada tal y como viene.
# Por la entrada estándar recibe línea de la forma:
# MAC IP
#
filtro_macs() {
   local device mac found on IFS cond

   while read -r device; do
      mac="${device% *}"
      # Si está encendido y debería estar encendido
      found=$(echo "$LISTP" | grep -Eoi '^'"$mac") && on="$on $found"
      if [ -n "$ON" ] && [ -z "$found" ]; then
         # Si está encendido y debería estar apagado
         if found=$(echo "$LIST" | grep -Ei '^'"$mac"); then
            set -- $found
            shift
            echo "$device '$*'"
         else
            echo "$device 'Dispositivo desconocido'"
         fi
      fi
   done
   # Listas las máquinas apagadas que deberían estar encendidas.
   if [ -n "$OFF" ]; then
      set -- $on
      if [ $# -gt 0 ]; then
         IFS="|"
         cond='$1 !~ /'"($*)/"
      fi
      echo "$LISTP" | awk "$cond "'{$2=sprintf("APAGADO \"%s", substr($2, 2)); print $0 "\""}'
   fi
}


#
# Formatea las líneas de salida.
# Su entrada es "MAC IP 'Descripción'"
#
formatear() {
   xargs -L1 printf "%17s [%15s] ... %s\n"
}


#
# Envía un mensaje de correo.
# $1: Texto del mensaje
#
send_mail() {
   echo "From: root@localhost
To: $mail
Subject: Informe sobre dispositivos encendidos/apagados.

$1" | sendmail -t
}


soy_root || error 1 "El scrip usa arp-scan que requiere permisos de administración"

#
# Tratamiento de argumentos
#
{
   IFACES=
   while [ $# -gt 0 ]; do
      case $1 in
         -h|--help)
            help
            exit 0
            ;;
         -i|--interface)
            check_arg "$2" || error 2 "Opción $1: Falta argumento"
            shift
            IFACES="$IFACES $1"
            ;;
         -l|--list)
            check_arg "$2" || error 2 "Opción $1: Falta argumento"
            shift
            LIST="$1"
            ;;
         -m|--mail)
            check_arg "$2" || error 2 "Opción $1: Falta argumento"
            shift
            MAIL="$1"
            ;;
         -o|--check-on)
            ON=1
            ;;
         -O|--check-off)
            OFF=1
            ;;
         -s|--stdout)
            STDOUT=1
            ;;
         *)
            error 2 "$1: Opción desconocida"
            ;;
      esac
      shift
   done

   # Si no se especifica qué se quiere hacer, se presupone
   # que la intención es compobar si se han quedado encendidos
   # los dispositivos que deberían estar apagados.
   [ -z "$ON$OFF" ] && ON=1

   [ -n "$STDOUT" ] && MAIL=
}

if [ -n "$MAIL" ] && ! which sendmail >/dev/null; then
   error 1 "Falta el ejecutable sendmail. Use -s si quiere imprimir por pantalla" 
fi

if [ ! -f "$LIST" ]; then 
   error 0 "'$LIST' no existe, por lo que no se usará."
   LIST=""
   [ -n "$OFF" ] && error 1 "Sin listado de máquinas no puede determinarse qué máquinas deberían estar encendidas"
else
   # Listado de máquinas que deberían estar encendidas.
   LISTP=$(awk '/^[^#]/ && $2 ~ /^-/ {print}' "$LIST")
   # Lista de máquinas que deberían estar apagadas.
   LIST=$(awk '/^[^#]/ && $2 !~ /^-/ {print}' "$LIST") || LIST=
fi

mensaje="$(get_ifaces $IFACES | xargs -n1 -P0 arp-scan -l -I | filtro_arp | formatear)"

[ -n "$mensaje" ] || return 0

mensaje="El sistema ha detectado que los siguientes dispositivos
o están encendidos sin tener por qué o están apagados debiendo
estar encendidos:

$mensaje
"


[ -n "$mail" ] && send_mail "$mensaje" || echo "$mensaje"
