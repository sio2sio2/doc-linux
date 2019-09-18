#!/bin/sh

# Analiza una opción que requiera argumento.
# $1: La opción
# $2: El argumento de la opción.
# $3: 1, si el argumento es opcional.
# Devuelve:
# 0: Si se pasó el argumento.
# 1: Si no se pasó argumento
# Imprime:
# El argumento suministrado.
optarg() {
   if [ -z "$2" ] || echo "$2" | grep -q '^-.'; then
      [ "$3" != "1" -a "$OPTERR" != "0" ] && echo "$1 requiere argumento" >&2
      exit 1
   else
      echo "$2"
   fi
}

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

# Análisis de las opciones.
while [ $# -gt 0 ]; do
   case $1 in
      -h|--help)  # Ayuda
         help
         exit 0
         ;;
      -f|--file)  # Opción con argumento obligatorio.
         FICHERO=$(optarg "$1" "$2")
         [ $? -eq 0 ] || exit 2
         shift 2
         ;;
      -p|--password)  # Opción con argumento opcional.
         PASSWORD=$(optarg "$1" "$2" 1)
         [ $? -eq 0 ] && shift
         shift
         ;;
      -v|--verbose)  # Opción sin argumento
         VERBOSE=1
         shift
         ;;
      --)  # Final de las opciones
         shift
         break
         ;;
      -?*)
         echo "$1: Opción desconocida" >&2
         exit 2
         ;;
      *) # Argumento posicional no asociado a opción: acabamos
         break
         ;;
   esac
done

# $@ contiene el resto de argumentos sin procesar.
echo "$@"
