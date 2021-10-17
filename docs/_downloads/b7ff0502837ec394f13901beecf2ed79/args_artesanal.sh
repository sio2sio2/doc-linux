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
trap '[ $? -ne 0 ] && help' EXIT

requiere_parametro() {
   expr "$1" : ".*$2:" > /dev/null
}


opts="hp:f:v"  # ":" significa que la opción requiere argumento propio

{ ### Análisis de las opciones.
   while [ $# -gt 0 ]; do
      case "$1" in
         -h|--help)  # Ayuda
            help
            exit 0
            ;;
         -f|--file)  # Opción con argumento obligatorio.
            [ -z "${2%%-*}" ] && echo "$1 requiere argumento" >&2 && exit 2
            ARCHIVO="$2"
            shift
            ;;
         -p|--password)  # Opción con argumento opcional.
            [ -z "${2%%-*}" ] && echo "$1 requiere argumento" >&2 && exit 2
            PASSWORD="$2"
            shift
            ;;
         -v|--verbose)  # Opción sin argumento
            VERBOSE=1
            ;;
         --)  # Final de las opciones
            shift
            break
            ;;
         --*|-?)
            echo "$1: Opción desconocida"
            exit 2
            ;;
         -??*)  # Separa opciones cortas y lo vuelve a intentar
            arg=$(printf "%.2s" "$1")
            arg=${arg#?}
            if requiere_parametro "$opts" "$arg"; then
               rarg="${1#-$arg}" 
            else
               rarg="-${1#-$arg}" 
            fi
            shift
            set -- -"$arg" "$rarg" "$@"
            continue
            ;;
         *)
            break
      esac
      shift
   done
}


echo "VERBOSE=$VERBOSE
ARCHIVO=$ARCHIVO
CONTRASEÑA=$PASSWORD
Posicionales: $*"
