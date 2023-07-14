#!/bin/sh

help() {
   echo "$(basename $0): Ilustra el procesamiento de las opciones de un script.

Opciones:
 -h, --help                      Muestra esta misma ayuda.
 -f, --file <FICHERO>            Fichero de entrada...
 -p, --password [<PASSWORD>]     Permite indicar la contraseña.
                                 Si no se indica, se pedirá interactivamente.
 -v, --verbose                   Ofrece información adicional
"
}

# Si se sale con un error, se muestra la ayuda.
trap '[ $? -eq 2 ] && help' EXIT

{ ### Análisis de las opciones.
   opts="hp:f:v"  # Como en getopts, ":" significa que requiere argumento propio

   post=0  # Cantidad de argumentos pospuestos no asociados a ninguna opción
   while [ $# -gt $post ]; do
      case "$1" in
         -h|--help)  # Ayuda
            help
            exit 0 ;;
         -f|--file)
            [ -z "$2" ] && echo "$1 requiere argumento" >&2 && exit 2
            ARCHIVO="$2"
            shift 2 ;;
         -p|--password)
            [ -z "$2" ] && echo "$1 requiere argumento" >&2 && exit 2
            PASSWORD="$2"
            shift 2 ;;
         -v|--verbose)
            VERBOSE=1
            shift ;;
         --)  # Final de las opciones
            shift
            break ;;
         --??*=*)  #1 --opt=value
            arg=${1%%=*}
            value=${1#*=}
            shift
            set -- "$arg" "$value" "$@" ;;
         --?*|-?)
            echo "$1: Opción desconocida"
            exit 2 ;;
         -??*)  #2 Fusión de opciones cortas
            rarg="${1#-?}" 
            arg="${1%$rarg}"
            shift
            # Si "arg" no necesita argumento, rarg no es su argumento, sino otra opción
            expr "$opts" : ".*${arg#-}:" > /dev/null || rarg="-$rarg" 
            set -- "$arg" "$rarg" "$@" ;;
         *)  #3 Argumentos no asociados a opciones no puestos al final
            arg=$1
            shift
            set -- "$@" "$arg"
            post=$((post+1)) ;;
      esac
   done
   # $@ contiene los argumentos no asociados a opciones.
}


echo "VERBOSE=$VERBOSE
ARCHIVO=$ARCHIVO
CONTRASEÑA=$PASSWORD
Posicionales: " "$@"
